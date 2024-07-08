import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDatasource {
  final AppDatabase _appDatabase;

  UserDatasource(this._appDatabase);

  Future<int> insertUser(UserModel user) async {
    return await _appDatabase.database.insert(
      AppDatabaseConfig.userTableName,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(UserModel user) async {
    await _appDatabase.database.update(
      AppDatabaseConfig.userTableName,
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteUser(String id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<UserModel?> getUser(String id) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) {
      return null;
    }

    return UserModel.fromJson(res.first);
  }
}
