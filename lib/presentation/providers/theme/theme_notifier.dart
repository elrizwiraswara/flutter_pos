import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/constants/constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/theme/theme_state.dart';

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final value = sharedPreferences.getString(Constants.selectedBrightnessKey);
    final isLight = value == 'light';
    final brightness = isLight ? Brightness.light : Brightness.dark;

    return ThemeState(
      isLight: isLight,
      themeData: AppTheme().init(brightness: brightness),
    );
  }

  void changeBrightness(bool isLight) async {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    await sharedPreferences.setString(
      Constants.selectedBrightnessKey,
      isLight ? 'light' : 'dark',
    );
    final brightness = isLight ? Brightness.light : Brightness.dark;
    state = ThemeState(
      isLight: isLight,
      themeData: AppTheme().init(brightness: brightness),
    );
  }
}
