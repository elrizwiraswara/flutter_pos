import 'package:flutter/material.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../core/services/connectivity/ping_service.dart';
import '../../../core/services/info/device_info_service.dart';
import '../../../domain/entities/queued_action_entity.dart';
import '../../../domain/entities/user_entity.dart' hide AuthProvider;
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/queued_action_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../../../domain/usecases/queued_action_usecases.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../../widgets/app_snack_bar.dart';
import '../auth/auth_provider.dart';
import '../products/products_provider.dart';

class MainProvider extends ChangeNotifier {
  final PingService pingService;
  final DeviceInfoService deviceInforService;
  final AuthProvider authProvider;
  final UserRepository userRepository;
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final QueuedActionRepository queuedActionRepository;

  MainProvider({
    required this.pingService,
    required this.deviceInforService,
    required this.authProvider,
    required this.transactionRepository,
    required this.userRepository,
    required this.productRepository,
    required this.queuedActionRepository,
  });

  bool isLoaded = false;
  bool isHasInternet = true;
  bool isHasQueuedActions = false;
  bool isSyncronizing = false;

  UserEntity? user;

  void resetStates() {
    isHasInternet = false;
    isHasInternet = true;
    isHasQueuedActions = false;
    isSyncronizing = false;
    user = null;
  }

  Future<void> initMainProvider() async {
    await startPingService();
    await getAndSyncAllUserData();
  }

  Future<void> startPingService() async {
    // Note: The ICMP protocol may not work on virtual devices
    final isPhysicalDevice = await deviceInforService.checkDeviceType();

    pingService.startPing(host: isPhysicalDevice ? '8.8.8.8' : '127.0.0.1');
    pingService.addConnectionStatusListener(
      (isConnected) => onHasInternet(isConnected),
    );
  }

  Future<void> checkAndSyncAllData() async {
    // Prevent sync during first time app open
    if (!isLoaded || !pingService.isConnected) return;

    try {
      isSyncronizing = true;
      notifyListeners();

      // Execute all queued actions
      int queueExecutedCount = await executeAllQueuedActions();

      // Sync all data
      await getAndSyncAllUserData();

      if (queueExecutedCount > 0) {
        AppSnackBar.show("$queueExecutedCount queues executed");
      }

      // Re-check queued actions
      checkIsHasQueuedActions();

      isSyncronizing = false;
      notifyListeners();
    } catch (e) {
      isSyncronizing = false;
      notifyListeners();

      AppSnackBar.showError('Failed to sync data\n\n${e.toString()}');
    }
  }

  Future<void> getAndSyncAllUserData() async {
    var userId = authProvider.user?.id;
    if (userId == null) throw 'Unathenticated!';

    // Run multiple futures simultaneusly
    // Because each repository has beed added data checker method
    // The local db will automatically sync with cloud db or vice versa
    var res = await Future.wait([
      GetUserUsecase(userRepository).call(userId),
      SyncAllUserProductsUsecase(productRepository).call(userId),
      SyncAllUserTransactionsUsecase(transactionRepository).call(userId),
    ]);

    // Set and notify user state
    if (res.first.isSuccess) {
      user = res.first.data as UserEntity?;
      notifyListeners();
    }

    if (res[1].isFailure) AppSnackBar.showError("Failed to sync product data");
    if (res[2].isFailure) AppSnackBar.showError("Failed to sync transaction data");

    // Refresh products list
    di<ProductsProvider>().getAllProducts();

    // Check queued actions
    checkIsHasQueuedActions();

    // Notify to MainScreen
    isLoaded = true;
    notifyListeners();
  }

  Future<int> executeAllQueuedActions() async {
    var queuedActions = await getQueuedActions();

    if (queuedActions.isNotEmpty) {
      var res = await ExecuteAllQueuedActionUsecase(queuedActionRepository).call(queuedActions);

      int executedCount = res.data?.where((e) => e).length ?? 0;
      return executedCount;
    }

    return 0;
  }

  Future<List<QueuedActionEntity>> getQueuedActions() async {
    var res = await GetAllQueuedActionUsecase(queuedActionRepository).call(NoParam());
    return res.data ?? [];
  }

  Future<void> onHasInternet(bool value) async {
    isHasInternet = value;
    notifyListeners();

    if (isHasInternet) checkAndSyncAllData();
  }

  Future<void> checkIsHasQueuedActions() async {
    isHasQueuedActions = (await getQueuedActions()).isEmpty;
    notifyListeners();
  }
}
