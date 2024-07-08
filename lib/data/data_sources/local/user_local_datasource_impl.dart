import 'package:flutter_pos/app/database/app_database.dart';
import 'package:flutter_pos/data/data_sources/interfaces/user_datasource.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserLocalDatasourceImpl extends UserDatasource {
  final AppDatabase _appDatabase;

  UserLocalDatasourceImpl(this._appDatabase);

  @override
  Future<String> createUser(UserModel user) async {
    user.id ??= user.email;
    await _appDatabase.database.insert(
      AppDatabaseConfig.userTableName,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return user.id!;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _appDatabase.database.update(
      AppDatabaseConfig.userTableName,
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<UserModel?> getUser(String id) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;

    return UserModel.fromJson(res.first);
  }
}
