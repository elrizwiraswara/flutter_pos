import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<UserEntity>> createUser(UserEntity user);
  Future<Result<UserEntity>> getUser(String userId);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(UserEntity user);
}
