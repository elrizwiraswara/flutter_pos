import 'dart:convert';

import '../../app/services/connectivity/connectivity_service.dart';
import '../../app/utilities/console_log.dart';
import '../../core/usecase/usecase.dart';
import '../data_sources/local/queued_action_local_datasource_impl.dart';
import '../models/product_model.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import 'product_repository_impl.dart';
import 'transaction_repository_impl.dart';
import 'user_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/queued_action_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/queued_action_repository.dart';
import '../../service_locator.dart';

class QueuedActionRepositoryImpl extends QueuedActionRepository {
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasourceImpl;

  QueuedActionRepositoryImpl({
    required this.queuedActionLocalDatasourceImpl,
  });
  @override
  Future<Result<List<QueuedActionEntity>>> getAllQueuedAction() async {
    var res = await queuedActionLocalDatasourceImpl.getAllUserQueuedAction();
    return Result.success(res.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<List<bool>>> executeAllQueuedActions(List<QueuedActionEntity> queues) async {
    if (queues.isEmpty) return Result.success([]);

    if (!ConnectivityService.isConnected) return Result.success([]);

    List<bool> result = [];

    for (var queue in queues) {
      var res = await executeQueuedAction(queue);

      if (res.isSuccess) {
        result.add(res.data ?? false);
      } else {
        result.add(false);
      }
    }

    return Result.success(result);
  }

  @override
  Future<Result<bool>> executeQueuedAction(QueuedActionEntity queue) async {
    try {
      cl("[executeQueuedAction].queue = ${QueuedActionModel.fromEntity(queue).toJson()}");

      var res = await _functionSelector(queue);

      if (res.isSuccess) {
        // Delete executed queue from db
        await queuedActionLocalDatasourceImpl.deleteQueuedAction(queue.id!);
        return Result.success(true);
      } else {
        return Result.error(null);
      }
    } catch (e) {
      return Result.error(null);
    }
  }

  Future<Result> _functionSelector(QueuedActionEntity queue) async {
    if (queue.repository == 'UserRepositoryImpl') {
      if (queue.method == 'createUser') {
        UserEntity param = UserModel.fromJson(jsonDecode(queue.param)).toEntity();
        return sl<UserRepositoryImpl>().createUser(param);
      }

      if (queue.method == 'deleteUser') {
        var param = queue.param;
        await sl<UserRepositoryImpl>().deleteUser(param);
        return Result.success(null);
      }

      if (queue.method == 'updateUser') {
        UserEntity param = UserModel.fromJson(jsonDecode(queue.param)).toEntity();
        await sl<UserRepositoryImpl>().updateUser(param);
        return Result.success(null);
      }
    }

    if (queue.repository == 'TransactionRepositoryImpl') {
      if (queue.method == 'createTransaction') {
        TransactionEntity param = TransactionModel.fromJson(jsonDecode(queue.param)).toEntity();
        return sl<TransactionRepositoryImpl>().createTransaction(param);
      }

      if (queue.method == 'deleteTransaction') {
        var param = int.parse(queue.param);
        await sl<TransactionRepositoryImpl>().deleteTransaction(param);
        return Result.success(null);
      }

      if (queue.method == 'updateTransaction') {
        TransactionEntity param = TransactionModel.fromJson(jsonDecode(queue.param)).toEntity();
        await sl<TransactionRepositoryImpl>().updateTransaction(param);
        return Result.success(null);
      }
    }

    if (queue.repository == 'ProductRepositoryImpl') {
      if (queue.method == 'createProduct') {
        ProductEntity param = ProductModel.fromJson(jsonDecode(queue.param)).toEntity();
        return sl<ProductRepositoryImpl>().createProduct(param);
      }

      if (queue.method == 'deleteProduct') {
        var param = int.parse(queue.param);
        await sl<ProductRepositoryImpl>().deleteProduct(param);
        return Result.success(null);
      }

      if (queue.method == 'updateProduct') {
        ProductEntity param = ProductModel.fromJson(jsonDecode(queue.param)).toEntity();
        await sl<ProductRepositoryImpl>().updateProduct(param);
        return Result.success(null);
      }
    }

    return Future.value(Result.success(null));
  }
}
