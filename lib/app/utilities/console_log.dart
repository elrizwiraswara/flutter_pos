import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Log something into console log on debug mode
void cl(dynamic text, {String? title, dynamic json}) {
  if (kDebugMode && !Platform.environment.containsKey('FLUTTER_TEST')) {
    String jsonPrettier(jsonObject) {
      var encoder = const JsonEncoder.withIndent("     ");
      return encoder.convert(jsonObject);
    }

    var logger = Logger(
      printer: PrettyPrinter(),
    );

    logger.d(
      '${title != null ? ('$title :') : ''}: $text ${json != null ? jsonPrettier(json) : ''}',
    );
  }
}
