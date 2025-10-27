import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';

class AppSnackBar {
  static Future<dynamic> show({
    required String message,
    bool isErrorMessage = false,
  }) async {
    final context = AppRoutes.instance.router.configuration.navigatorKey.currentContext;
    if (context == null) throw Exception('No context available for snack bar');

    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isErrorMessage ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
    );
  }
}
