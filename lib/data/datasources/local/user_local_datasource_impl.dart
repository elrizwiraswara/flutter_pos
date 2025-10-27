import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';
import '../../../app/database/app_database_config.dart';
import '../../../core/common/result.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserLocalDatasourceImpl extends UserDatasource {
  final AppDatabase _appDatabase;

  UserLocalDatasourceImpl(this._appDatabase);

  @override
  Future<Result<String>> createUser(UserModel user) async {
    try {
      await _appDatabase.database.insert(
        AppDatabaseConfig.userTableName,
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
      await _appDatabase.database.update(
        AppDatabaseConfig.userTableName,
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
      await _appDatabase.database.delete(
        AppDatabaseConfig.userTableName,
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
      var res = await _appDatabase.database.query(
        AppDatabaseConfig.userTableName,
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
