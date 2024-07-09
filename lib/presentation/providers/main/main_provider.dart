import 'package:flutter/material.dart';
import 'package:flutter_pos/app/const/const.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/app/services/connectivity/connectivity_service.dart';
import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/queued_action_entity.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/repositories/queued_action_repository.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';
import 'package:flutter_pos/domain/usecases/product_usecases.dart';
import 'package:flutter_pos/domain/usecases/ququed_action_usecases.dart';
import 'package:flutter_pos/domain/usecases/transaction_usecases.dart';
import 'package:flutter_pos/domain/usecases/user_usecases.dart';
import 'package:flutter_pos/presentation/providers/products/products_provider.dart';
import 'package:flutter_pos/service_locator.dart';

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
  bool isHasInternet = false;
  bool isDataSynced = false;
  bool isSyncronizing = false;

  UserEntity? user;

  Future<void> initMainProvider() async {
    isLoaded = false;
    notifyListeners();

    await ConnectivityService.initNetworkChecker(onHasInternet: onHasInternet);

    await checkAndSaveAllData();

    isLoaded = true;
    notifyListeners();
  }

  Future<void> checkAndSyncAllData() async {
    final context = AppRoutes.rootNavigatorKey.currentState!.context;
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text(SYNCRONIZING_MESSAGE)));

      isSyncronizing = true;
      notifyListeners();

      await checkAndSaveAllData();

      // Check and execute all queued actions
      int queueExecutedCount = await checkAndExecutePendingQueue();

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text("$SYNCED_MESSAGE! ${queueExecutedCount > 0 ? "$queueExecutedCount queues executed" : ""}"),
        ),
      );

      isSyncronizing = false;
      isDataSynced = true;
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

  Future<void> checkAndSaveAllData() async {
    var auth = AuthService().getAuthData();
    if (auth == null) return;

    // Run multiple futures simultaneusly
    // Because each repository has beed added data checker method
    // The local db will automatically sync with cloud db or vice versa
    var res = await Future.wait([
      GetUserUsecase(userRepository).call(auth.uid),
      GetAllProductsUsecase(productRepository).call(auth.uid),
      GetAllTransactionsUsecase(transactionRepository).call(auth.uid),
    ]);

    // Set and notify user state
    if (res.first.isSuccess) {
      user = res.first.data as UserEntity?;
      notifyListeners();
    }

    // Refresh products list
    sl<ProductsProvider>().getAllProducts();
  }

  Future<int> checkAndExecutePendingQueue() async {
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

  Future<void> onHasInternet(bool value) async {
    isHasInternet = value;
    isDataSynced = (await getQueuedActions()).isNotEmpty;
    notifyListeners();

    if (isHasInternet) checkAndSyncAllData();
  }
}
