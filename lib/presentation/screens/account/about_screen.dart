import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/assets/assets.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/external_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        titleSpacing: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppImage(
                image: Assets.welcome,
                imgProvider: ImgProvider.assetImage,
                width: 150,
              ),
              const SizedBox(height: AppSizes.padding),
              Text(
                'Flutter POS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                packageName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                'version $version',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSizes.padding),
              Text(
                'A Point of Sale (POS) application built with Flutter, demonstrating Clean Architecture principles and offline-first design patterns.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSizes.padding * 2),
              Text(
                "This project serves as a learning resource and reference implementation for building Flutter apps with proper architecture and automatic data synchronization between local storage (SQLite) and cloud database (Firestore).\n\nThe app prioritizes local-first operations, storing all data in SQLite and automatically syncing with Firestore when online. When offline, all user actions (create, update, delete) are recorded as QueuedActions in the local database and automatically executed in sequence when internet connectivity is restored.",
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSizes.padding),
              Row(
                children: [
                  Text(
                    "Developed with ❤️ by",
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Elriz Wiraswara",
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "GitHub",
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  onTap: () {
                    ExternalLauncher.openUrl('https://github.com/elrizwiraswara');
                  },
                ),
              ),
              const SizedBox(height: AppSizes.padding / 4),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Website",
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  onTap: () {
                    ExternalLauncher.openUrl('https://elriztechnology.com');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
