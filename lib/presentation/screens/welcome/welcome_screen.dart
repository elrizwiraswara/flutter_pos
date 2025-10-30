import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/assets.dart';
import '../../../core/themes/app_sizes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: body()),
    );
  }

  Widget body() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      padding: const EdgeInsets.all(AppSizes.padding),
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
    );
  }
}
