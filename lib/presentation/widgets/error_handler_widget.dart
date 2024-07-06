import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/console_log.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:go_router/go_router.dart';

class ErrorHandlerWidget extends StatefulWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;

  const ErrorHandlerWidget({super.key, this.errorDetails, this.errorMessage});

  @override
  ErrorHandlerWidgetState createState() => ErrorHandlerWidgetState();
}

class ErrorHandlerWidgetState extends State<ErrorHandlerWidget> {
  @override
  void initState() {
    onError();
    super.initState();
  }

  // Error handling logic
  void onError() {
    // Add your error handling logic here, e.g., logging, reporting to a server, etc.
    cl("ERROR: ${widget.errorDetails}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding * 4),
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
                widget.errorMessage ?? 'Something went wrong.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.padding),
              // Only show error details to UI on Debug Mode
              if (kDebugMode)
                Text(
                  widget.errorDetails?.summary.toString() ?? '(No error summary)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w100,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              const SizedBox(height: AppSizes.padding * 2),
              AppButton(
                text: 'Back to home',
                onTap: () {
                  GoRouter.of(context).go('/home');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
