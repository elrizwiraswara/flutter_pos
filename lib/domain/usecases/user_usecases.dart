import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';

class GetUserUsecase extends UseCase<Result, String> {
  GetUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity>> call(String params) async => _userRepository.getUser(params);
}

class CreateUserUsecase extends UseCase<Result, UserEntity> {
  CreateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<String>> call(UserEntity params) async => _userRepository.createUser(params);
}

class UpateUserUsecase extends UseCase<void, UserEntity> {
  UpateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<void> call(UserEntity params) async => _userRepository.updateUser(params);
}

class DeleteUserUsecase extends UseCase<void, String> {
  DeleteUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<void> call(String params) async => _userRepository.deleteUser(params);
}
