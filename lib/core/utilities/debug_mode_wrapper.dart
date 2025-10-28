import 'dart:io';

import 'package:flutter/foundation.dart';

class DebugModeWrapper {
  bool get isDebugMode => kDebugMode;
  bool get isFlutterTestMode => Platform.environment.containsKey('FLUTTER_TEST');
}
