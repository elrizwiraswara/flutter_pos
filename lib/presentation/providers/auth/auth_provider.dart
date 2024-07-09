import 'package:flutter/foundation.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/auth/auth_service.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../../widgets/app_dialog.dart';

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
      email: authData.email,
      name: authData.displayName ?? '',
      imageUrl: authData.photoURL,
      phone: authData.phoneNumber ?? '',
      birthdate: null,
    );

    await CreateUserUsecase(userRepository).call(user);
  }
}
