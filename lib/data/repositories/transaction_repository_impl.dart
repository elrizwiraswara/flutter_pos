import 'dart:convert';

import '../../app/const/app_const.dart';
import '../../app/services/connectivity/ping_service.dart';
import '../../core/common/result.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/transaction_local_datasource_impl.dart';
import '../datasources/remote/transaction_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final PingService pingService;
  final TransactionLocalDatasourceImpl transactionLocalDatasource;
  final TransactionRemoteDatasourceImpl transactionRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  TransactionRepositoryImpl({
    required this.pingService,
    required this.transactionLocalDatasource,
    required this.transactionRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserTransactions(String userId) async {
    try {
      if (pingService.isConnected) {
        var local = await transactionLocalDatasource.getAllUserTransactions(userId);
        if (local.isFailure) return Result.failure(error: local.error!);

        var remote = await transactionRemoteDatasource.getAllUserTransactions(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        var res = await syncTransactions(local.data!, remote.data!);

        // Sum all local and remote sync counts
        int totalSyncedCount = res.$1 + res.$2;

        // Return synced data count
        return Result.success(data: totalSyncedCount);
      }

      return Result.success(data: 0);
    } catch (e) {
      return Result.failure(error: e);
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

      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        var remote = await transactionRemoteDatasource.getUserTransactions(
          userId,
          orderBy: orderBy,
          sortBy: sortBy,
          limit: limit,
          offset: offset,
          contains: contains,
        );

        if (remote.isFailure) return Result.failure(error: remote.error!);

        var res = await syncTransactions(local.data!, remote.data!);

        int syncedToLocalCount = res.$1;
        int syncedToRemoteCount = res.$2;

        // If more data was synced to the local, return the remote data
        if (syncedToLocalCount > syncedToRemoteCount) {
          // Return remote data
          return Result.success(data: remote.data!.map((e) => e.toEntity()).toList());
        } else {
          // Return local data
          return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
        }
      }

      return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<TransactionEntity?>> getTransaction(int transactionId) async {
    try {
      var local = await transactionLocalDatasource.getTransaction(transactionId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        var remote = await transactionRemoteDatasource.getTransaction(transactionId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        List<TransactionModel> localToList = [if (local.data != null) local.data!];
        List<TransactionModel> remoteToList = [if (remote.data != null) remote.data!];

        var res = await syncTransactions(localToList, remoteToList);

        int syncedToLocalCount = res.$1;
        int syncedToRemoteCount = res.$2;

        // If more data was synced to the local, return the remote data
        if (syncedToLocalCount > syncedToRemoteCount) {
          // Return remote data
          return Result.success(data: remote.data?.toEntity());
        } else {
          // Return local data
          return Result.success(data: local.data?.toEntity());
        }
      }

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      var local = await transactionLocalDatasource.createTransaction(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await transactionRemoteDatasource.createTransaction(data);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'createTransaction',
            param: jsonEncode((data).toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int transactionId) async {
    try {
      final local = await transactionLocalDatasource.deleteTransaction(transactionId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await transactionRemoteDatasource.deleteTransaction(transactionId);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'deleteTransaction',
            param: transactionId.toString(),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      final local = await transactionLocalDatasource.updateTransaction(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await transactionRemoteDatasource.updateTransaction(data);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'updateTransaction',
            param: jsonEncode(data.toJson()),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  // Perform a sync between local and remote data
  Future<(int, int)> syncTransactions(List<TransactionModel> local, List<TransactionModel> remote) async {
    int syncedToLocalCount = 0;
    int syncedToRemoteCount = 0;

    // Track processed IDs to avoid duplicate syncing
    final processedIds = <int>{};

    // Process local transactions first
    for (final localData in local) {
      final matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

      if (matchRemoteData != null) {
        // Mark as processed
        processedIds.add(localData.id);

        final updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? '');
        final updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? '');

        // Skip if either timestamp is invalid
        if (updatedAtLocal == null || updatedAtRemote == null) continue;

        final differenceInMinutes = updatedAtRemote.difference(updatedAtLocal).inMinutes;
        final isDiffSignificant = differenceInMinutes.abs() > AppConst.minSyncIntervalToleranceForCriticalInMinutes;

        // Check which is newer based on the difference
        final isRemoteNewer = isDiffSignificant && differenceInMinutes > 0;
        final isLocalNewer = isDiffSignificant && differenceInMinutes < 0;

        if (isRemoteNewer) {
          // Save remote data to local db
          final res = await transactionLocalDatasource.updateTransaction(matchRemoteData);
          if (res.isSuccess) syncedToLocalCount += 1;
        } else if (isLocalNewer) {
          // Update remote with local data
          final res = await transactionRemoteDatasource.updateTransaction(localData);
          if (res.isSuccess) syncedToRemoteCount += 1;
        }
        // If not significant difference, do nothing (already in sync)
      } else {
        // No matching remote transaction, create it
        processedIds.add(localData.id);
        final res = await transactionRemoteDatasource.createTransaction(localData);
        if (res.isSuccess) syncedToRemoteCount += 1;
      }
    }

    // Process remaining remote transactions that weren't in local
    for (final remoteData in remote) {
      // Skip if already processed in the first loop
      if (processedIds.contains(remoteData.id)) continue;

      // No matching local transaction, create it locally
      final res = await transactionLocalDatasource.createTransaction(remoteData);
      if (res.isSuccess) syncedToLocalCount += 1;
    }

    return (syncedToLocalCount, syncedToRemoteCount);
  }
}
