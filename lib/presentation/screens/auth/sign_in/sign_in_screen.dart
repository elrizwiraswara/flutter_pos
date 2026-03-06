import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/assets/assets.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            _WelcomeMessage(),
            _SignInButton(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
}

class _SignInButton extends ConsumerWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      text: 'Sign In With Google',
      onTap: () async {
        var res = await AppDialog.showProgress(() async {
          return ref.read(authControllerProvider).signIn();
        });

        if (res.isSuccess) {
          ref.read(appRoutesProvider).router.refresh();
        } else {
          AppDialog.showError(error: res.error?.toString());
        }
      },
    );
  }
}
