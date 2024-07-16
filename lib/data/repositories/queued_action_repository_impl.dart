import 'dart:convert';

import '../../app/services/connectivity/connectivity_service.dart';
import '../../app/utilities/console_log.dart';
import '../../core/errors/errors.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/queued_action_entity.dart';
import '../../domain/repositories/queued_action_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/remote/product_remote_datasource_impl.dart';
import '../datasources/remote/transaction_remote_datasource_impl.dart';
import '../datasources/remote/user_remote_datasource_impl.dart';
import '../models/product_model.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class QueuedActionRepositoryImpl extends QueuedActionRepository {
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;
  final UserRemoteDatasourceImpl userRemoteDatasource;
  final TransactionRemoteDatasourceImpl transactionRemoteDatasource;
  final ProductRemoteDatasourceImpl productRemoteDatasource;

  QueuedActionRepositoryImpl({
    required this.queuedActionLocalDatasource,
    required this.userRemoteDatasource,
    required this.transactionRemoteDatasource,
    required this.productRemoteDatasource,
  });

  @override
  Future<Result<List<QueuedActionEntity>>> getAllQueuedAction() async {
    try {
      var res = await queuedActionLocalDatasource.getAllUserQueuedAction();
      return Result.success(res.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<List<bool>>> executeAllQueuedActions(List<QueuedActionEntity> queues) async {
    try {
      if (queues.isEmpty) return Result.success([]);

      List<bool> result = [];

      for (var queue in queues) {
        // Pass if the internet goes off in the process
        if (!ConnectivityService.isConnected) continue;

        var res = await executeQueuedAction(queue);

        if (res.isSuccess) {
          result.add(res.data ?? false);
        } else {
          result.add(false);
        }
      }

      return Result.success(result);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> executeQueuedAction(QueuedActionEntity queue) async {
    try {
      cl("[executeQueuedAction].queue = ${QueuedActionModel.fromEntity(queue).toJson()}");

      var res = await _functionSelector(queue).catchError((e) {
        return Result.error(APIError(message: e.toString()));
      });

      if (res.isSuccess) {
        // Delete executed queue from db
        await queuedActionLocalDatasource.deleteQueuedAction(queue.id!);
        return Result.success(true);
      } else {
        cl("[executeQueuedAction].error = ${res.error}");
        return Result.error(res.error);
      }
    } catch (e) {
      cl("[executeQueuedAction].error = $e");
      return Result.error(APIError(message: e.toString()));
    }
  }

  Future<Result> _functionSelector(QueuedActionEntity queue) async {
    if (queue.repository == 'UserRepositoryImpl') {
      if (queue.method == 'createUser') {
        UserModel param = UserModel.fromJson(jsonDecode(queue.param));
        await userRemoteDatasource.createUser(param);
        return Result.success(null);
      }

      if (queue.method == 'deleteUser') {
        var param = queue.param;
        await userRemoteDatasource.deleteUser(param);
        return Result.success(null);
      }

      if (queue.method == 'updateUser') {
        UserModel param = UserModel.fromJson(jsonDecode(queue.param));
        await userRemoteDatasource.updateUser(param);
        return Result.success(null);
      }
    }

    if (queue.repository == 'TransactionRepositoryImpl') {
      if (queue.method == 'createTransaction') {
        TransactionModel param = TransactionModel.fromJson(jsonDecode(queue.param));
        await transactionRemoteDatasource.createTransaction(param);
        return Result.success(null);
      }

      if (queue.method == 'deleteTransaction') {
        var param = int.parse(queue.param);
        await transactionRemoteDatasource.deleteTransaction(param);
        return Result.success(null);
      }

      if (queue.method == 'updateTransaction') {
        TransactionModel param = TransactionModel.fromJson(jsonDecode(queue.param));
        await transactionRemoteDatasource.updateTransaction(param);
        return Result.success(null);
      }
    }

    if (queue.repository == 'ProductRepositoryImpl') {
      if (queue.method == 'createProduct') {
        ProductModel param = ProductModel.fromJson(jsonDecode(queue.param));
        await productRemoteDatasource.createProduct(param);
        return Result.success(null);
      }

      if (queue.method == 'deleteProduct') {
        var param = int.parse(queue.param);
        await productRemoteDatasource.deleteProduct(param);
        return Result.success(null);
      }

      if (queue.method == 'updateProduct') {
        ProductModel param = ProductModel.fromJson(jsonDecode(queue.param));
        await productRemoteDatasource.updateProduct(param);
        return Result.success(null);
      }
    }

    return Future.value(Result.success(null));
  }
}
