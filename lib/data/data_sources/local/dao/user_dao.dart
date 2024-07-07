import 'package:floor/floor.dart';
import 'package:flutter_pos/data/models/user_model.dart';

@dao
abstract class UserDao {
  @insert
  Future<void> insertUser(UserModel user);

  @update
  Future<void> updateUser(UserModel user);

  @delete
  Future<void> deleteUser(UserModel user);

  @Query('SELECT * FROM user WHERE id = :id')
  Future<UserModel?> findUserById(String id);
}
