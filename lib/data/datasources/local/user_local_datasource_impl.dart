import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserLocalDatasourceImpl extends UserDatasource {
  final DatabaseService _databaseService;

  UserLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<String>> createUser(UserModel user) async {
    try {
      await _databaseService.database.insert(
        DatabaseConfig.userTableName,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id is uid from GoogleSignIn credential
      return Result.success(data: user.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.userTableName,
        user.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getUser(String id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: UserModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
