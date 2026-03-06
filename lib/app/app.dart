import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/locale/app_locale.dart';
import 'di/app_providers.dart';
import 'error/error_handler_builder.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider.select((provider) => provider.theme));
    final router = ref.watch(appRoutesProvider).router;

    return MaterialApp.router(
      title: 'Flutter POS',
      theme: theme,
      debugShowCheckedModeBanner: kDebugMode,
      routerConfig: router,
      locale: AppLocale.defaultLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.localizationsDelegates,
      builder: (context, child) => ErrorHandlerBuilder(child: child),
    );
  }
}
