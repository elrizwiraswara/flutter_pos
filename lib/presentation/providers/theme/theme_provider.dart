import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _sharedPreferences;

  ThemeProvider(this._sharedPreferences);

  ThemeData get theme {
    final value = _sharedPreferences.getString(Constants.selectedBrightnessKey);
    var brightness = value == 'light' ? Brightness.light : Brightness.dark;
    return AppTheme().init(brightness: brightness);
  }

  void changeBrightness(bool isLight) async {
    await _sharedPreferences.setString(Constants.selectedBrightnessKey, isLight ? 'light' : 'dark');
    notifyListeners();
  }

  bool isLight() => theme.brightness == Brightness.light;
}
