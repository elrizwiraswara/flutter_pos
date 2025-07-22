import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../app/assets/app_assets.dart';
import '../../app/themes/app_sizes.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
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
    );
  }
}
