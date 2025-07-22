import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/database/app_database.dart';
import 'app/locale/app_locale.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'presentation/providers/theme/theme_provider.dart';
import 'presentation/screens/error_handler_screen.dart';
import 'service_locator.dart';

void main() async {
  // Initialize binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (use `flutterfire configure` to generate the options)
  await Firebase.initializeApp(
    name: DefaultFirebaseOptions.currentPlatform.projectId,
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize app local db
  await AppDatabase().init();

  // Ensure persistence is cleared
  await FirebaseFirestore.instance.clearPersistence();

  // Initialize flutter_dotenv
  await dotenv.load();

  // Initialize date formatting
  initializeDateFormatting();

  // Setup service locator
  setupServiceLocator();

  // Set/lock screen orientation
  SystemChrome.setPreferredOrientations([]);

  // Set Default SystemUIOverlayStyle
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Selector<ThemeProvider, ThemeData>(
        selector: (context, provider) => provider.theme,
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: 'Flutter POS',
            theme: theme,
            debugShowCheckedModeBanner: kDebugMode,
            routerConfig: AppRoutes.router,
            locale: AppLocale.defaultLocale,
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: AppLocale.localizationsDelegates,
            builder: (context, child) => ErrorHandlerBuilder(child: child),
          );
        },
      ),
    );
  }
}
