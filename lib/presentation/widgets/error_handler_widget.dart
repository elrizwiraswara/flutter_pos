import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/console_log.dart';

class ErrorHandlerWidget extends StatefulWidget {
  final Widget? child;

  const ErrorHandlerWidget({super.key, this.child});

  @override
  ErrorHandlerWidgetState createState() => ErrorHandlerWidgetState();
}

class ErrorHandlerWidgetState extends State<ErrorHandlerWidget> {
  // Error handling logic
  void onError(FlutterErrorDetails errorDetails) {
    // Add your error handling logic here, e.g., logging, reporting to a server, etc.
    cl("ERROR: $errorDetails");
  }

  @override
  Widget build(BuildContext context) {
    return ErrorWidgetBuilder(
      builder: (context, errorDetails) {
        // Display a user-friendly error screen
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              children: [
                Text(
                  'Oops!',
                  style:
                      Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).colorScheme.onError),
                ),
                const SizedBox(height: AppSizes.padding),
                Text(
                  'Something went wrong. Please try again later.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                // Only show error details to UI on Debug Mode
                if (kDebugMode)
                  Text(
                    errorDetails.toString(),
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.surface),
                  ),
              ],
            ),
          ),
        );
      },
      onError: onError,
      child: widget.child ?? const SizedBox(),
    );
  }
}

class ErrorWidgetBuilder extends StatefulWidget {
  final Widget Function(BuildContext, FlutterErrorDetails) builder;
  final void Function(FlutterErrorDetails) onError;
  final Widget child;

  const ErrorWidgetBuilder({
    super.key,
    required this.builder,
    required this.onError,
    required this.child,
  });

  @override
  ErrorWidgetBuilderState createState() => ErrorWidgetBuilderState();
}

class ErrorWidgetBuilderState extends State<ErrorWidgetBuilder> {
  @override
  void initState() {
    super.initState();
    // Set up global error handling
    FlutterError.onError = widget.onError;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
