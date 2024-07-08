import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<UserEntity>> getUser(String userId);
  Future<Result<String>> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
}
