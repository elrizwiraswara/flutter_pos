import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/assets/assets.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            welcomeMessage(context),
            signInButton(),
          ],
        ),
      ),
    );
  }

  Widget welcomeMessage(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppImage(
              image: Assets.welcome,
              imgProvider: ImgProvider.assetImage,
            ),
            const SizedBox(height: AppSizes.padding),
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Welcome to Flutter POS app',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget signInButton() {
    return AppButton(
      text: 'Sign In With Google',
      onTap: () async {
        var res = await AppDialog.showProgress(() async {
          return await di<AuthProvider>().signIn();
        });

        if (res.isSuccess) {
          AppRoutes.instance.router.refresh();
        } else {
          AppDialog.showError(error: res.error?.toString());
        }
      },
    );
  }
}
