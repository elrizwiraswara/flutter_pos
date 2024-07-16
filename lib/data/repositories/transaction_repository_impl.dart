import 'dart:convert';

import '../../app/const/const.dart';
import '../../app/services/connectivity/connectivity_service.dart';
import '../../core/errors/errors.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/transaction_local_datasource_impl.dart';
import '../datasources/remote/transaction_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionLocalDatasourceImpl transactionLocalDatasource;
  final TransactionRemoteDatasourceImpl transactionRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  TransactionRepositoryImpl({
    required this.transactionLocalDatasource,
    required this.transactionRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserTransactions(String userId) async {
    try {
      if (ConnectivityService.isConnected) {
        var local = await transactionLocalDatasource.getAllUserTransactions(userId);
        var remote = await transactionRemoteDatasource.getAllUserTransactions(userId);

        if (remote.isEmpty && local.isNotEmpty) {
          for (var data in local) {
            // Store local data to remote db
            await transactionRemoteDatasource.createTransaction(data);
          }

          // Return synced data count
          return Result.success(local.length);
        }

        if (remote.isNotEmpty && local.isEmpty) {
          for (var data in remote) {
            // Store remote data to local db
            await transactionLocalDatasource.createTransaction(data);
          }

          // Return synced data count
          return Result.success(remote.length);
        }

        int syncedDataCount = 0;

        if (remote.isNotEmpty && local.isNotEmpty) {
          // Local first
          for (var localData in local) {
            var matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

            if (matchRemoteData != null) {
              // Compare local & remote data updatedAt difference
              var updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? DateTime.now().toIso8601String());
              var updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? DateTime.now().toIso8601String());
              var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
              // Check is the difference is above the minimum interval sync tolerance
              var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
              var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

              if (isRemoteNewer) {
                syncedDataCount += 1;
                // Save remote data to local db
                await transactionLocalDatasource.updateTransaction(matchRemoteData);
              }

              if (isLocalNewer) {
                syncedDataCount += 1;
                // Update remote with local data
                await transactionRemoteDatasource.updateTransaction(localData);
              }
            } else {
              syncedDataCount += 1;
              // No matching remote data, create it
              await transactionRemoteDatasource.createTransaction(localData);
            }
          }

          // Remote first
          for (var remoteData in remote) {
            var matchLocalData = local.where((localData) => localData.id == remoteData.id).firstOrNull;

            if (matchLocalData != null) {
              // Compare local & remote data updatedAt difference
              var updatedAtLocal = DateTime.tryParse(remoteData.updatedAt ?? DateTime.now().toIso8601String());
              var updatedAtRemote = DateTime.tryParse(matchLocalData.updatedAt ?? DateTime.now().toIso8601String());
              var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
              // Check is the difference is above the minimum interval sync tolerance
              var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
              var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

              if (isRemoteNewer) {
                syncedDataCount += 1;
                // Save remote data to local db
                await transactionLocalDatasource.updateTransaction(remoteData);
              }

              if (isLocalNewer) {
                syncedDataCount += 1;
                // Update remote with local data
                await transactionRemoteDatasource.updateTransaction(matchLocalData);
              }
            } else {
              syncedDataCount += 1;
              // No matching local data, create it
              await transactionLocalDatasource.createTransaction(remoteData);
            }
          }
        }

        // Return synced data count
        return Result.success(syncedDataCount);
      }

      return Result.success(0);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getUserTransactions(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      var local = await transactionLocalDatasource.getUserTransactions(
        userId,
        orderBy: orderBy,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
        contains: contains,
      );

      if (ConnectivityService.isConnected) {
        var remote = await transactionRemoteDatasource.getUserTransactions(
          userId,
          orderBy: orderBy,
          sortBy: sortBy,
          limit: limit,
          offset: offset,
          contains: contains,
        );

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

          // Local first only
          for (var localData in local) {
            var matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

            if (matchRemoteData != null) {
              // Compare local & remote data updatedAt difference
              var updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? DateTime.now().toIso8601String());
              var updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? DateTime.now().toIso8601String());
              var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
              // Check is the difference is above the minimum interval sync tolerance
              var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
              var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

              if (isRemoteNewer) {
                isRemoteHasNewerData.add(true);
                // Save remote data to local db
                await transactionLocalDatasource.updateTransaction(matchRemoteData);
              }

              if (isLocalNewer) {
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
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<TransactionEntity>> getTransaction(int transactionId) async {
    try {
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
          // Return remote
          return Result.success(remote.toEntity());
        }

        if (remote != null && local != null) {
          // Compare local & remote data updatedAt difference
          var updatedAtLocal = DateTime.tryParse(local.updatedAt ?? DateTime.now().toIso8601String());
          var updatedAtRemote = DateTime.tryParse(remote.updatedAt ?? DateTime.now().toIso8601String());
          var differenceInMinutes = updatedAtRemote?.difference(updatedAtLocal!).inMinutes ?? 0;
          // Check is the difference is above the minimum interval sync tolerance
          var isRemoteNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;
          var isLocalNewer = differenceInMinutes.abs() > MIN_SYNC_INTERVAL_TOLERANCE_FOR_CRITICAL_IN_MINUTES;

          if (isRemoteNewer) {
            // Save remote data to local db
            await transactionLocalDatasource.updateTransaction(remote);
            // Return remote data
            return Result.success(remote.toEntity());
          }

          if (isLocalNewer) {
            // Store local data to remote db
            await transactionRemoteDatasource.updateTransaction(local);
            // Return local data
            return Result.success(local.toEntity());
          }
        }
      }

      return Result.success(local?.toEntity());
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      var id = await transactionLocalDatasource.createTransaction(data);

      if (ConnectivityService.isConnected) {
        await transactionRemoteDatasource.createTransaction(data);
      } else {
        await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'createTransaction',
            param: jsonEncode((data).toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      return Result.success(id);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int transactionId) async {
    try {
      await transactionLocalDatasource.deleteTransaction(transactionId);

      if (ConnectivityService.isConnected) {
        await transactionRemoteDatasource.deleteTransaction(transactionId);
      } else {
        await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'deleteTransaction',
            param: transactionId.toString(),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      await transactionLocalDatasource.updateTransaction(data);

      if (ConnectivityService.isConnected) {
        await transactionRemoteDatasource.updateTransaction(data);
      } else {
        await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'updateTransaction',
            param: jsonEncode(data.toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(APIError(message: e.toString()));
    }
  }
}
