import 'package:flutter/foundation.dart';

class ErrorScreenParam {
  final Object? error;
  final FlutterErrorDetails? flutterError;
  final StackTrace? stackTrace;
  final String? message;

  ErrorScreenParam({
    this.error,
    this.flutterError,
    this.stackTrace,
    this.message,
  });
}
