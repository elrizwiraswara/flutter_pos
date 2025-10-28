import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';

class AppSnackBar {
  static Future<dynamic> show(String message) async {
    _getMessengerAndTheme.$1.hideCurrentSnackBar();
    _getMessengerAndTheme.$1.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getMessengerAndTheme.$2.colorScheme.tertiary,
      ),
    );
  }

  static Future<dynamic> showError(String errorMessage) async {
    _getMessengerAndTheme.$1.hideCurrentSnackBar();
    _getMessengerAndTheme.$1.showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: _getMessengerAndTheme.$2.colorScheme.error,
      ),
    );
  }

  static (ScaffoldMessengerState, ThemeData) get _getMessengerAndTheme {
    final context = AppRoutes.instance.router.configuration.navigatorKey.currentContext;
    if (context == null) throw Exception('No context available for snack bar');

    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    return (messenger, theme);
  }
}
