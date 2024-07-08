import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';

class GetUser extends UseCase<Result, String> {
  GetUser(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity>> call(String params) async => _userRepository.getUser(params);
}

class CreateUser extends UseCase<Result, UserEntity> {
  CreateUser(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<int>> call(UserEntity params) async => _userRepository.createUser(params);
}

class UpateUser extends UseCase<void, UserEntity> {
  UpateUser(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<void> call(UserEntity params) async => _userRepository.updateUser(params);
}

class DeleteUser extends UseCase<void, String> {
  DeleteUser(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<void> call(String params) async => _userRepository.deleteUser(params);
}
