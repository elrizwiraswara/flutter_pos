import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';
import 'package:flutter_pos/domain/usecases/user_usecases.dart';
import 'package:flutter_pos/presentation/widgets/app_dialog.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository userRepository;

  AuthProvider({required this.userRepository});

  void signIn() async {
    try {
      AppDialog.showDialogProgress();

      var res = await AuthService().signIn();

      AppDialog.closeDialog();

      if (res.isSuccess) {
        await saveUser();
        AppRoutes.router.refresh();
      } else {
        AppDialog.showErrorDialog(error: res.error?.error);
      }
    } catch (e) {
      AppDialog.showErrorDialog(error: e.toString());
    }
  }

  Future<void> saveUser() async {
    var authData = AuthService().getAuthData();

    var user = UserEntity(
      id: authData!.uid,
      name: authData.displayName ?? '',
      imageUrl: authData.photoURL,
      phone: authData.phoneNumber ?? '',
      birthdate: null,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await CreateUserUsecase(userRepository).call(user);
  }
}
