import 'dart:convert';

import '../../app/const/app_const.dart';
import '../../app/services/connectivity/ping_service.dart';
import '../../core/common/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/user_local_datasource_impl.dart';
import '../datasources/remote/user_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  final PingService pingService;
  final UserLocalDatasourceImpl userLocalDatasource;
  final UserRemoteDatasourceImpl userRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  UserRepositoryImpl({
    required this.pingService,
    required this.userLocalDatasource,
    required this.userRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<UserEntity?>> getUser(String userId) async {
    try {
      var local = await userLocalDatasource.getUser(userId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        var remote = await userRemoteDatasource.getUser(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        var res = await _syncUser(local.data, remote.data);

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
  Future<Result<String>> createUser(UserEntity user) async {
    try {
      var local = await userLocalDatasource.createUser(UserModel.fromEntity(user));
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.createUser(UserModel.fromEntity(user)..id = local.data!);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'createUser',
            param: jsonEncode((UserModel.fromEntity(user)..id = local.data!).toJson()),
            isCritical: false,
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
  Future<Result<void>> deleteUser(String userId) async {
    try {
      final local = await userLocalDatasource.deleteUser(userId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.deleteUser(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'deleteUser',
            param: userId,
            isCritical: false,
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
  Future<Result<void>> updateUser(UserEntity user) async {
    try {
      final local = await userLocalDatasource.updateUser(UserModel.fromEntity(user));
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.updateUser(UserModel.fromEntity(user));
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'updateUser',
            param: jsonEncode(UserModel.fromEntity(user).toJson()),
            isCritical: false,
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
  Future<(int, int)> _syncUser(UserModel? local, UserModel? remote) async {
    int syncedToLocalCount = 0;
    int syncedToRemoteCount = 0;

    if (remote == null && local != null) {
      // Store local data to remote db
      final res = await userRemoteDatasource.createUser(local);
      if (res.isSuccess) syncedToRemoteCount += 1;
    } else if (remote != null && local == null) {
      // Store remote data to local db
      final res = await userLocalDatasource.createUser(remote);
      if (res.isSuccess) syncedToLocalCount += 1;
    } else if (remote != null && local != null) {
      // Both exist, compare timestamps
      final updatedAtLocal = DateTime.tryParse(local.updatedAt ?? '');
      final updatedAtRemote = DateTime.tryParse(remote.updatedAt ?? '');

      // Skip if either timestamp is invalid
      if (updatedAtLocal == null || updatedAtRemote == null) {
        return (syncedToLocalCount, syncedToRemoteCount);
      }

      final differenceInMinutes = updatedAtRemote.difference(updatedAtLocal).inMinutes;
      final isDiffSignificant = differenceInMinutes.abs() > AppConst.minSyncIntervalToleranceForLessCriticalInMinutes;

      // Check which is newer based on the difference
      final isRemoteNewer = isDiffSignificant && differenceInMinutes > 0;
      final isLocalNewer = isDiffSignificant && differenceInMinutes < 0;

      if (isRemoteNewer) {
        // Save remote data to local db
        final res = await userLocalDatasource.updateUser(remote);
        if (res.isSuccess) syncedToLocalCount += 1;
      } else if (isLocalNewer) {
        // Store local data to remote db
        final res = await userRemoteDatasource.updateUser(local);
        if (res.isSuccess) syncedToRemoteCount += 1;
      }
      // If not significant difference, do nothing (already in sync)
    }

    return (syncedToLocalCount, syncedToRemoteCount);
  }
}
