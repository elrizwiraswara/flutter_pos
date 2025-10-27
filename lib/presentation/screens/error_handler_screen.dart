import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/service_locator.dart';

import '../../app/routes/app_routes.dart';
import '../../app/routes/params/error_screen_param.dart';
import '../../app/services/logger/error_logger_service.dart';
import '../../app/themes/app_sizes.dart';
import '../../app/utilities/console_logger.dart';
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
  final _errorLoggerService = sl<ErrorLoggerService>();

  @override
  void initState() {
    super.initState();

    // Set up custom widget error
    ErrorWidget.builder = (error) => _errorWidget(context: context, error: error);

    // Called whenever the Flutter framework catches an error
    FlutterError.onError = onFlutterError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      return true;
    };
  }

  // Flutter error handling logic
  void onFlutterError(FlutterErrorDetails flutterError) {
    cl('[onFlutterError].error = ${flutterError.exception}', type: LogType.error);

    _errorLoggerService.log(error: flutterError);

    // Prevent to push to ErrorScreen multiple times
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) return;

      if (AppRoutes.instance.router.routeInformationProvider.value.uri.path != '/error') {
        AppRoutes.instance.router.go('/error', extra: {'flutterError': flutterError});
      }
    });
  }

  // Platform error handling logic
  Future<bool> onPlatformError(Object error, StackTrace stackTrace) async {
    cl('[onFlutterError].error = $error', type: LogType.error);

    _errorLoggerService.log(error: error, stackTrace: stackTrace);

    // Prevent to push to ErrorScreen multiple times
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) return;

      if (AppRoutes.instance.router.routeInformationProvider.value.uri.path != '/error') {
        AppRoutes.instance.router.go('/error', extra: {'error': error, 'stackTrace': stackTrace});
      }
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

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
            _errorWidget(
              context: context,
              error: param.error ?? param.flutterError,
              message: param.message,
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
                AppRoutes.instance.router.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _errorWidget({
  required BuildContext context,
  Object? error,
  String? message,
}) {
  cl('[_errorWidget].error = $error', type: LogType.error);

  return Center(
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
              message ?? 'Something went wrong.\nPlease try again later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.padding),
            // Only show error details to UI on Debug Mode
            if (kDebugMode)
              Text(
                "${error is FlutterErrorDetails ? error.summary : error ?? '(No error details)'}",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w100,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
