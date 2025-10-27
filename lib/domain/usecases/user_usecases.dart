import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserUsecase extends Usecase<Result, String> {
  GetUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity?>> call(String params) async => _userRepository.getUser(params);
}

class CreateUserUsecase extends Usecase<Result, UserEntity> {
  CreateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<String>> call(UserEntity params) async {
    final currentUser = await _userRepository.getUser(params.id);

    if (currentUser.data != null) {
      return Result.success(data: currentUser.data!.id);
    }

    return await _userRepository.createUser(params);
  }
}

class UpateUserUsecase extends Usecase<Result<void>, UserEntity> {
  UpateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(UserEntity params) async => _userRepository.updateUser(params);
}

class DeleteUserUsecase extends Usecase<Result<void>, String> {
  DeleteUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(String params) async => _userRepository.deleteUser(params);
}
