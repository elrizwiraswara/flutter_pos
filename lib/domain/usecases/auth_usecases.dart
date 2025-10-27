import 'package:flutter_pos/domain/usecases/params/no_param.dart';

import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase extends Usecase<Result, NoParam> {
  SignInWithGoogleUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.signInWithGoogle();
}

class SignOutUsecase extends Usecase<Result, NoParam> {
  SignOutUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(NoParam params) async => _authRepository.signOut();
}

class GetCurrentUserUsecase extends Usecase<Result, NoParam> {
  GetCurrentUserUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.getCurrentUser();
}
