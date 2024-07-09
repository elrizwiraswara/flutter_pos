import 'dart:convert';

import '../../app/const/const.dart';
import '../../app/services/connectivity/connectivity_service.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/user_local_datasource_impl.dart';
import '../datasources/remote/user_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  final UserLocalDatasourceImpl userLocalDatasource;
  final UserRemoteDatasourceImpl userRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasourceImpl;

  UserRepositoryImpl({
    required this.userLocalDatasource,
    required this.userRemoteDatasource,
    required this.queuedActionLocalDatasourceImpl,
  });

  @override
  Future<Result<UserEntity>> getUser(String userId) async {
    var local = await userLocalDatasource.getUser(userId);

    if (ConnectivityService.isConnected) {
      var remote = await userRemoteDatasource.getUser(userId);

      if (remote == null && local != null) {
        // Store local data to remote db
        await userRemoteDatasource.createUser(local);
        // Return local data
        return Result.success(local.toEntity());
      }

      if (remote != null && local == null) {
        // Store remote data to local db
        await userLocalDatasource.createUser(remote);
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
          await userLocalDatasource.updateUser(remote);
          // Return remote data
          return Result.success(remote.toEntity());
        } else {
          // Store local data to remote db
          await userRemoteDatasource.updateUser(local);
          // Return local data
          return Result.success(local.toEntity());
        }
      }
    }

    return Result.success(local?.toEntity());
  }

  @override
  Future<Result<String>> createUser(UserEntity user) async {
    var id = await userLocalDatasource.createUser(UserModel.fromEntity(user));

    if (ConnectivityService.isConnected) {
      await userRemoteDatasource.createUser(UserModel.fromEntity(user)..id = id);
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'UserRepositoryImpl',
          method: 'createUser',
          param: jsonEncode((UserModel.fromEntity(user)..id = id).toJson()),
          isCritical: false,
        ),
      );
    }

    return Result.success(id);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await userLocalDatasource.deleteUser(userId);

    if (ConnectivityService.isConnected) {
      await userRemoteDatasource.deleteUser(userId);
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'UserRepositoryImpl',
          method: 'deleteUser',
          param: userId,
          isCritical: false,
        ),
      );
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await userLocalDatasource.updateUser(UserModel.fromEntity(user));

    if (ConnectivityService.isConnected) {
      await userRemoteDatasource.updateUser(UserModel.fromEntity(user));
    } else {
      await queuedActionLocalDatasourceImpl.createQueuedAction(
        QueuedActionModel(
          repository: 'UserRepositoryImpl',
          method: 'updateUser',
          param: jsonEncode(UserModel.fromEntity(user).toJson()),
          isCritical: false,
        ),
      );
    }
  }
}
