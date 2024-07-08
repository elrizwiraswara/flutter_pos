import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/user_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/user_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  final UserLocalDatasourceImpl userLocalDatasource;
  final UserRemoteDatasourceImpl userRemoteDatasource;

  UserRepositoryImpl({required this.userLocalDatasource, required this.userRemoteDatasource});

  @override
  Future<Result<UserEntity>> getUser(String userId) async {
    var res = await userLocalDatasource.getUser(userId);
    return Result.success(res?.toEntity());
  }

  @override
  Future<Result<String>> createUser(UserEntity user) async {
    var id = await userLocalDatasource.createUser(UserModel.fromEntity(user));
    return Result.success(id);
  }

  @override
  Future<void> deleteUser(String userId) async {
    return await userLocalDatasource.deleteUser(userId);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    return await userLocalDatasource.updateUser(UserModel.fromEntity(user));
  }
}
