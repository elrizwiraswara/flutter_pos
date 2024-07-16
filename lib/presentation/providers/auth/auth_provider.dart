import 'package:flutter/foundation.dart';

import '../../../app/services/auth/auth_service.dart';
import '../../../core/errors/errors.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/user_usecases.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository userRepository;

  AuthProvider({required this.userRepository});

  Future<Result<String>> signIn() async {
    try {
      var res = await AuthService().signIn();

      if (res.isHasError) {
        return Result.error(res.error);
      }

      var saveUserRes = await saveUser();

      return saveUserRes;
    } catch (e) {
      return Result.error(UnknownError(message: e.toString()));
    }
  }

  Future<Result<String>> saveUser() async {
    var authData = AuthService().getAuthData();

    var user = UserEntity(
      id: authData!.uid,
      email: authData.email,
      name: authData.displayName ?? '',
      imageUrl: authData.photoURL,
      phone: authData.phoneNumber ?? '',
      birthdate: null,
    );

    return await CreateUserUsecase(userRepository).call(user);
  }
}
