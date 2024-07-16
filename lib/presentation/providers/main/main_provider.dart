import 'package:flutter/material.dart';

import '../../../app/const/const.dart';
import '../../../app/services/auth/auth_service.dart';
import '../../../app/services/connectivity/connectivity_service.dart';
import '../../../domain/entities/queued_action_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/queued_action_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/params/no_params.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../../../domain/usecases/ququed_action_usecases.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../../../service_locator.dart';
import '../products/products_provider.dart';

class MainProvider extends ChangeNotifier {
  final UserRepository userRepository;
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final QueuedActionRepository queuedActionRepository;

  MainProvider({
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

  Future<void> initMainProvider(BuildContext context) async {
    ConnectivityService.initNetworkChecker(onHasInternet: (value) => onHasInternet(context, value));
    await getAndSyncAllUserData();
  }

  Future<void> checkAndSyncAllData(BuildContext context) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Prevent sync during first time app open
    if (!isLoaded) return;

    if (!ConnectivityService.isConnected) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text(SYNC_PENDING_MESSAGE)));
      return;
    }

    try {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text(SYNCRONIZING_MESSAGE)));

      isSyncronizing = true;
      notifyListeners();

      // Execute all queued actions
      int queueExecutedCount = await executeAllQueuedActions();

      // Sync all data
      await getAndSyncAllUserData();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text("$SYNCED_MESSAGE! ${queueExecutedCount > 0 ? "$queueExecutedCount queues executed" : ""}"),
        ),
      );

      // Re-check queued actions
      checkIsHasQueuedActions();

      isSyncronizing = false;
      notifyListeners();
    } catch (e) {
      isSyncronizing = false;
      notifyListeners();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to sync data\n\n${e.toString()}'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> getAndSyncAllUserData() async {
    var auth = AuthService().getAuthData();
    if (auth == null) throw 'Unauthenticated';

    // Run multiple futures simultaneusly
    // Because each repository has beed added data checker method
    // The local db will automatically sync with cloud db or vice versa
    var res = await Future.wait([
      GetUserUsecase(userRepository).call(auth.uid),
      SyncAllUserProductsUsecase(productRepository).call(auth.uid),
      SyncAllUserTransactionsUsecase(transactionRepository).call(auth.uid),
    ]);

    // Set and notify user state
    if (res.isNotEmpty && res.first.isSuccess) {
      user = res.first.data as UserEntity?;
      notifyListeners();
    }

    // Refresh products list
    sl<ProductsProvider>().getAllProducts();

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
    var res = await GetAllQueuedActionUsecase(queuedActionRepository).call(NoParams());
    return res.data ?? [];
  }

  Future<void> onHasInternet(BuildContext context, bool value) async {
    isHasInternet = value;
    notifyListeners();

    if (isHasInternet) checkAndSyncAllData(context);
  }

  Future<void> checkIsHasQueuedActions() async {
    isHasQueuedActions = (await getQueuedActions()).isEmpty;
    notifyListeners();
  }
}
