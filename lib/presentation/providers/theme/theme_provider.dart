import 'package:flutter/material.dart';

import '../../../app/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData theme = AppTheme().init();

  void changeBrightness(bool isLight) {
    var brightness = isLight ? Brightness.light : Brightness.dark;
    theme = AppTheme().init(brightness: brightness);
    notifyListeners();
  }

  bool isLight() => theme.brightness == Brightness.light;
}
