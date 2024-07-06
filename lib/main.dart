import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos/app/themes/app_theme.dart';
import 'package:flutter_pos/firebase_options.dart';
import 'package:flutter_pos/presentation/widgets/error_handler_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/locale/app_locale.dart';
import 'app/routes/app_routes.dart';
import 'service_locator.dart';

void main() async {
  // Initialize binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  initializeDateFormatting();

  // Setup service locator
  setupServiceLocator();

  // Initialize multiple futures
  await Future.wait([
    // Initialize Firebase (google-service.json required)
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  // Set/lock screen orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set Default SystemUIOverlayStyle
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme().init();

    return MultiProvider(
      providers: providers,
      child: MaterialApp.router(
        title: 'Flutter POS',
        theme: theme,
        debugShowCheckedModeBanner: kDebugMode,
        routerConfig: AppRoutes.router,
        locale: AppLocale.defaultLocale,
        supportedLocales: AppLocale.supportedLocales,
        localizationsDelegates: AppLocale.localizationsDelegates,
        builder: (context, child) => ErrorHandlerWidget(child: child),
      ),
    );
  }
}
