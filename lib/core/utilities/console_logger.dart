import 'dart:convert';

import 'package:logger/logger.dart';

import 'debug_mode_wrapper.dart';

enum LogType {
  debug,
  error,
  info,
  warning,
  trace,
}

final _logPrinter = Logger(
  printer: PrettyPrinter(
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    printEmojis: false,
  ),
);

final _debugModeWrapper = DebugModeWrapper();

/// Convenience function for quick printing anything into console only on debug mode
void cl(
  dynamic any, {
  String? title,
  String? message,
  String? state,
  LogType type = LogType.info,
}) {
  if (!_debugModeWrapper.isDebugMode || _debugModeWrapper.isFlutterTestMode) return;

  // Check if only 'any' has a value (others are null)
  bool onlyAnyHasValue = title == null && message == null && state == null && any != null;

  String parsed;

  if (onlyAnyHasValue) {
    // Print only the 'any' value without prefix
    parsed = any is Map ? _jsonPrettier(any) : any.toString();
  } else {
    // Build the formatted string, only including non-null values
    List<String> parts = [];

    parts.add(_buildLogContext(title: title, message: message, state: state));

    if (any != null) {
      parts.add(
        'Detail  : ${any is Map ? _jsonPrettier(any) : any}',
      );
    }

    parsed = parts.join('\n');
  }

  if (type == LogType.debug) {
    return _logPrinter.d(parsed);
  }

  if (type == LogType.error) {
    return _logPrinter.e(parsed);
  }

  if (type == LogType.info) {
    return _logPrinter.i(parsed);
  }

  if (type == LogType.warning) {
    return _logPrinter.w(parsed);
  }

  if (type == LogType.trace) {
    return _logPrinter.t(parsed);
  }
}

/// Build a log context string from optional title, message, and state
String _buildLogContext({
  String? title,
  String? message,
  String? state,
}) {
  List<String> parts = [];

  if (title != null) {
    parts.add('Title   : $title');
  }

  if (message != null) {
    parts.add('Message : $message');
  }

  if (state != null) {
    parts.add('State   : $state');
  }

  return parts.join('\n');
}

/// Prettify a JSON object for better readability in logs
String _jsonPrettier(Object? jsonObject) {
  if (jsonObject == null) return 'null';

  try {
    var encoder = const JsonEncoder.withIndent('     ');
    return encoder.convert(jsonObject);
  } catch (e) {
    // If the object is not a valid JSON, return its string representation
    return jsonObject.toString();
  }
}
