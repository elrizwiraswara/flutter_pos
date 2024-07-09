import 'package:flutter/material.dart';
import '../../../../app/assets/app_assets.dart';
import '../../../../app/themes/app_sizes.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_image.dart';
import '../../../../service_locator.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _authProvider = sl<AuthProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            welcomeMessage(),
            signInButton(),
          ],
        ),
      ),
    );
  }

  Widget welcomeMessage() {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppImage(
              image: AppAssets.welcome,
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
      onTap: _authProvider.signIn,
    );
  }
}
