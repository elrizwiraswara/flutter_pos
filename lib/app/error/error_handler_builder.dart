import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/logger/error_logger_service.dart';
import '../../core/utilities/console_logger.dart';
import '../../presentation/widgets/app_error_widget.dart';
import '../di/dependency_injection.dart';
import '../routes/app_routes.dart';

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
  final _errorLoggerService = di<ErrorLoggerService>();

  @override
  void initState() {
    super.initState();
    // Set up custom widget error
    ErrorWidget.builder = (error) => AppErrorWidget(error: error);

    // Called whenever the Flutter framework catches an error
    FlutterError.onError = onFlutterError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      return true;
    };
  }

  // Flutter error handling logic
  void onFlutterError(FlutterErrorDetails flutterError) {
    ce(flutterError.exception);

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
    ce(error);

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
