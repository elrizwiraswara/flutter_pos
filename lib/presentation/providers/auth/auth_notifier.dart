import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../core/utilities/console_logger.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/user_usecases.dart';
import 'auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _initialize();
    return const AuthState(isChecking: true);
  }

  Future<void> _initialize() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final res = await GetCurrentUserUsecase(authRepository).call(NoParam());

      final user = res.data;
      cl('isAuthenticated: ${user != null}');

      state = AuthState(user: user);
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<Result<String>> signIn() async {
    final authRepository = ref.read(authRepositoryProvider);
    final userRepository = ref.read(userRepositoryProvider);

    var res = await SignInWithGoogleUsecase(authRepository).call(NoParam());
    if (res.isFailure) return Result.failure(error: res.error!);

    var createRes = await CreateUserUsecase(userRepository).call(res.data!);
    if (createRes.isFailure) return Result.failure(error: createRes.error!);

    state = AuthState(user: res.data!);

    return createRes;
  }

  Future<Result<void>> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);

    final res = await SignOutUsecase(authRepository).call(NoParam());
    if (res.isFailure) return Result.failure(error: res.error!);

    state = const AuthState();

    return Result.success(data: null);
  }
}
