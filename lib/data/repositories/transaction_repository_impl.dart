import 'dart:convert';

import 'package:flutter_pos/app/const/const.dart';
import 'package:flutter_pos/app/services/connectivity/connectivity_service.dart';
import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/local/transaction_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/transaction_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/queued_action_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionLocalDatasourceImpl transactionLocalDatasource;
  final TransactionRemoteDatasourceImpl transactionRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasourceImpl;

  TransactionRepositoryImpl({
    required this.transactionLocalDatasource,
    required this.transactionRemoteDatasource,
    required this.queuedActionLocalDatasourceImpl,
  });

  @override
  Future<Result<List<TransactionEntity>>> getAllUserTransactions(String userId) async {
    var local = await transactionLocalDatasource.getAllUserTransactions(userId);

    if (ConnectivityService.isConnected) {
      var remote = await transactionRemoteDatasource.getAllUserTransactions(userId);

      if (remote.isEmpty && local.isNotEmpty) {
        for (var data in local) {
          // Store local data to remote db
          await transactionRemoteDatasource.createTransaction(data);
        }

        // Return local data
        return Result.success(local.map((e) => e.toEntity()).toList());
      }

      if (remote.isNotEmpty && local.isEmpty) {
        for (var data in remote) {
          // Store remote data to local db
          await transactionLocalDatasource.createTransaction(data);
        }

        // Return remote data
        return Result.success(remote.map((e) => e.toEntity()).toList());
      }

      if (remote.isNotEmpty && local.isNotEmpty) {
        List<bool> isRemoteHasNewerData = [];

        for (var localData in local) {
          var matchRemoteData = remote.where((remoteProduct) => remoteProduct.id == localData.id).firstOrNull;

          if (matchRemoteData != null) {
            var updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? DateTime.now().toIso8601String());
            var updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? DateTime.now().toIso8601String());
            var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
            var isRemoteNewer = differenceInMinutes > MIN_SYNC_INTERVAL_TOLERANCE_FOR_LESS_CRITICAL_IN_MINUTES;

            if (isRemoteNewer) {
              isRemoteHasNewerData.add(true);
              // Save remote data to local db
              await transactionLocalDatasource.updateTransaction(matchRemoteData);
            } else {
              // Update remote with local data
              await transactionRemoteDatasource.updateTransaction(localData);
            }
          } else {
            // No matching remote product, create it
            await transactionRemoteDatasource.createTransaction(localData);
          }
        }

        if (isRemoteHasNewerData.contains(true)) {
          // Return remote data
          return Result.success(remote.map((e) => e.toEntity()).toList());
        } else {
          // Return local data
          return Result.success(local.map((e) => e.toEntity()).toList());
        }
      }
    }

    return Result.success(local.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<TransactionEntity>> getTransaction(int transactionId) async {
    var local = await transactionLocalDatasource.getTransaction(transactionId);

    if (ConnectivityService.isConnected) {
      var remote = await transactionRemoteDatasource.getTransaction(transactionId);

      if (remote == null && local != null) {
        // Store local data to remote db
        await transactionRemoteDatasource.createTransaction(local);
        // Return local data
        return Result.success(local.toEntity());
      }

      if (remote != null && local == null) {
        // Store remote data to local db
        await transactionLocalDatasource.createTransaction(remote);
        // Return remote data
        return Result.success(remote.toEntity());
      }

      if (remote != null && local != null) {
        var updatedAtLocal = DateTime.tryParse(local.updatedAt ?? DateTime.now().toIso8601String());
        var updatedAtRemote = DateTime.tryParse(remote.updatedAt ?? DateTime.now().toIso8601String());
        var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
        var isRemoteNewer = differenceInMinutes > MIN_SYNC_INTERVAL_TOLERANCE_FOR_LESS_CRITICAL_IN_MINUTES;

        // Compare local & remote data updatedAt difference
        if (isRemoteNewer) {
          // Save remote data to local db
          await transactionLocalDatasource.updateTransaction(remote);
          // Return remote data
          return Result.success(remote.toEntity());
        } else {
          // Store local data to remote db
          await transactionRemoteDatasource.updateTransaction(local);
          // Return local data
          return Result.success(local.toEntity());
        }
      }
    }

    return Result.success(local?.toEntity());
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    var id = await transactionLocalDatasource.createTransaction(TransactionModel.fromEntity(transaction));

    if (ConnectivityService.isConnected) {
      await transactionRemoteDatasource.createTransaction(TransactionModel.fromEntity(transaction)..id = id);
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'TransactionRepositoryImpl',
          method: 'createTransaction',
          param: jsonEncode((TransactionModel.fromEntity(transaction)..id = id).toJson()),
          isCritical: true,
        ),
      );
    }

    return Result.success(id);
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    await transactionLocalDatasource.deleteTransaction(transactionId);

    if (ConnectivityService.isConnected) {
      await transactionRemoteDatasource.deleteTransaction(transactionId);
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'TransactionRepositoryImpl',
          method: 'deleteTransaction',
          param: transactionId.toString(),
          isCritical: true,
        ),
      );
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    await transactionLocalDatasource.updateTransaction(TransactionModel.fromEntity(transaction));

    if (ConnectivityService.isConnected) {
      await transactionRemoteDatasource.updateTransaction(TransactionModel.fromEntity(transaction));
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'TransactionRepositoryImpl',
          method: 'updateTransaction',
          param: jsonEncode(TransactionModel.fromEntity(transaction).toJson()),
          isCritical: true,
        ),
      );
    }
  }
}
