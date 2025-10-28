import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/themes/app_sizes.dart';
import '../../core/utilities/console_logger.dart';

class AppErrorWidget extends StatelessWidget {
  final Object? error;
  final String? message;

  const AppErrorWidget({super.key, this.error, this.message});

  @override
  Widget build(BuildContext context) {
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
                  "${error is FlutterErrorDetails ? (error as FlutterErrorDetails).summary : error ?? '(No error details)'}",
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
}
