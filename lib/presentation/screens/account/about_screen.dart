import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/themes/app_sizes.dart';
import '../../../app/utilities/external_launcher.dart';

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
                image: AppAssets.welcome,
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
                'A simple Point of Sale (POS) application\nbuilt with Flutter with clean architecture design',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSizes.padding * 2),
              Text(
                "This application is designed to be used both online and offline. The application's local data (sqflite) will be automatically synchronized with the cloud data (firestore) when the application detects an internet connection.\n\nThis application uses an offline-first approach, where data will be stored in the local database first and then in the cloud database if there is an internet connection. If there is no internet connection, all actions performed by the user (create, update, delete) will be recorded as 'QueuedActions' in local database and will be executed automatically when the internet connection available.",
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
