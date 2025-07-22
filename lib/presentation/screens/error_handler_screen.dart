import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_sizes.dart';
import '../../app/utilities/console_log.dart';
import '../widgets/app_button.dart';

class ErrorHandlerBuilder extends StatefulWidget {
  final Widget? child;

  const ErrorHandlerBuilder({
    super.key,
    this.child,
  });

  @override
  ErrorHandlerBuilderState createState() => ErrorHandlerBuilderState();
}

class ErrorHandlerBuilderState extends State<ErrorHandlerBuilder> {
  @override
  void initState() {
    super.initState();
    // Set up global error handling
    FlutterError.onError = onError;
  }

  // Error handling logic
  void onError(FlutterErrorDetails errorDetails) {
    // Add your error handling logic here, e.g., logging, reporting to a server, etc.
    cl('[ErrorHandlerBuilder].error = ${errorDetails.exception}');

    // Prevent to push to ErrorScreen multiple times
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) return;

      if (AppRoutes.router.routeInformationProvider.value.uri.path != '/error') {
        AppRoutes.router.go('/error', extra: errorDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;

  const ErrorScreen({super.key, this.errorDetails, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.report,
                  size: 100,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSizes.padding / 4),
                Text(
                  'Oops!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSizes.padding),
                Text(
                  errorMessage ?? 'Something went wrong.\nPlease try again later.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.padding),
                // Only show error details to UI on Debug Mode
                if (kDebugMode)
                  Text(
                    errorDetails?.summary.toString() ?? '(No error summary)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w100,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                const SizedBox(height: AppSizes.padding * 2),
                AppButton(
                  buttonColor: Theme.of(context).colorScheme.surface,
                  borderColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  textColor: Theme.of(context).colorScheme.primary,
                  alignment: null,
                  text: 'Back to home',
                  onTap: () {
                    // Go back to default initial route
                    GoRouter.of(context).go('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
