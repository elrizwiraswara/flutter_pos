import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

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

class UpateUserUsecase extends UseCase<Result<void>, UserEntity> {
  UpateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(UserEntity params) async => _userRepository.updateUser(params);
}

class DeleteUserUsecase extends UseCase<Result<void>, String> {
  DeleteUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(String params) async => _userRepository.deleteUser(params);
}
