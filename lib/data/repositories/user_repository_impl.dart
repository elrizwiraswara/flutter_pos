import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/user_datasource.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  final UserDatasource _userDatasource;

  UserRepositoryImpl(this._userDatasource);

  @override
  Future<Result<UserEntity>> getUser(String userId) async {
    var res = await _userDatasource.getUser(userId);
    return Result.success(res?.toEntity());
  }

  @override
  Future<Result<int>> createUser(UserEntity user) async {
    var id = await _userDatasource.insertUser(UserModel.fromEntity(user));
    return Result.success(id);
  }

  @override
  Future<void> deleteUser(String userId) async {
    return await _userDatasource.deleteUser(userId);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    return await _userDatasource.updateUser(UserModel.fromEntity(user));
  }
}
