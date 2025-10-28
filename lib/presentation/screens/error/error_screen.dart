import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/routes/params/error_screen_param.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_error_widget.dart';

class ErrorScreen extends StatelessWidget {
  final ErrorScreenParam param;

  const ErrorScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(
              error: param.error ?? param.flutterError,
              message: param.message,
            ),
            const SizedBox(height: AppSizes.padding),
            AppButton(
              buttonColor: Theme.of(context).colorScheme.surface,
              borderColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              textColor: Theme.of(context).colorScheme.primary,
              alignment: null,
              text: 'Back to home',
              onTap: () {
                // Go back to default initial route
                AppRoutes.instance.router.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
