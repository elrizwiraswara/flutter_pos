import 'package:flutter/foundation.dart';

import '../../../core/common/result.dart';
import '../../../core/utilities/console_logger.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/user_usecases.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  AuthProvider({
    required this.userRepository,
    required this.authRepository,
  }) {
    initialize();
  }

  bool isAuthenticated = false;
  bool isChecking = true;

  UserEntity? _user;
  UserEntity? get user => _user;

  Future<void> initialize() async {
    try {
      isChecking = true;
      notifyListeners();

      final res = await GetCurrentUserUsecase(authRepository).call(NoParam());

      _user = res.data;
      cl('isAuthenticated: ${_user != null}');
    } finally {
      isChecking = false;
      isAuthenticated = _user != null;
      notifyListeners();
    }
  }

  Future<Result<String>> signIn() async {
    var res = await SignInWithGoogleUsecase(authRepository).call(NoParam());
    if (res.isFailure) return Result.failure(error: res.error!);

    var createRes = await CreateUserUsecase(userRepository).call(res.data!);
    if (createRes.isFailure) return Result.failure(error: createRes.error!);

    _user = res.data;
    isAuthenticated = true;
    notifyListeners();

    return createRes;
  }

  Future<Result<void>> signOut() async {
    final res = await SignOutUsecase(authRepository).call(NoParam());
    if (res.isFailure) return Result.failure(error: res.error!);

    _user = null;
    isAuthenticated = false;
    notifyListeners();

    return Result.success(data: null);
  }
}
