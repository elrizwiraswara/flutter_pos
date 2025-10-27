import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/utilities/console_logger.dart';

import '../../../core/common/result.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../../widgets/app_dialog.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;

  AuthProvider({
    required this.userRepository,
    required this.authRepository,
  });

  bool get isAuthenticated => user != null;

  UserEntity? _user;
  UserEntity? get user => _user;

  Future<void> checkIsAuthenticated() async {
    final res = await GetCurrentUserUsecase(authRepository).call(NoParam());

    _user = res.data;
    notifyListeners();

    cl('[checkIsAuthenticated].isAuthenticated: ${_user != null}');
  }

  Future<Result<String>> signIn() async {
    return await AppDialog.showDialogProgress(() async {
      var res = await SignInWithGoogleUsecase(authRepository).call(NoParam());
      if (res.isFailure) return Result.failure(error: res.error!);

      var createRes = await CreateUserUsecase(userRepository).call(res.data!);
      if (createRes.isFailure) return Result.failure(error: createRes.error!);

      _user = res.data;
      notifyListeners();

      return createRes;
    });
  }

  Future<Result<void>> signOut() async {
    return await AppDialog.showDialogProgress(() async {
      final res = await SignOutUsecase(authRepository).call(NoParam());
      if (res.isFailure) return Result.failure(error: res.error!);

      _user = null;
      notifyListeners();

      return Result.success(data: null);
    });
  }
}
