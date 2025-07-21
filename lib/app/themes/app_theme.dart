import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  /// Make [AppTheme] to be singleton
  static final AppTheme _instance = AppTheme._();

  factory AppTheme() => _instance;

  AppTheme._();

  Color _primaryColor = AppColors.orange;
  Color? _secondaryColor = AppColors.charcoal;
  Color? _tertiaryColor = AppColors.plum;
  Brightness _brightness = Brightness.light;
  TextTheme _primaryTextTheme = GoogleFonts.latoTextTheme();
  TextTheme _secondaryTextTheme = GoogleFonts.poppinsTextTheme();

  ThemeData init({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
    Brightness? brightness,
    TextTheme? primaryTextTheme,
    TextTheme? secondaryTextTheme,
  }) {
    _primaryColor = primaryColor ?? _primaryColor;
    _secondaryColor = secondaryColor ?? _secondaryColor;
    _tertiaryColor = tertiaryColor ?? _tertiaryColor;
    _brightness = brightness ?? _brightness;
    _primaryTextTheme = primaryTextTheme ?? _primaryTextTheme;
    _secondaryTextTheme = secondaryTextTheme ?? _secondaryTextTheme;

    return _base(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: _brightness,
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _tertiaryColor,
      ),
      brightness: _brightness,
      primaryTextTheme: _primaryTextTheme,
      secondaryTextTheme: _secondaryTextTheme,
    );
  }

  ThemeData _base({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required TextTheme primaryTextTheme,
    required TextTheme secondaryTextTheme,
  }) {
    final textTheme = primaryTextTheme.copyWith(
      displaySmall: secondaryTextTheme.displaySmall,
      displayMedium: secondaryTextTheme.displayMedium,
      displayLarge: secondaryTextTheme.displayLarge,
      headlineSmall: secondaryTextTheme.headlineSmall,
      headlineMedium: secondaryTextTheme.headlineMedium,
      headlineLarge: secondaryTextTheme.headlineLarge,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
        decorationColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shadowColor: colorScheme.surfaceContainerHighest,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        titleSpacing: AppSizes.padding,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurface,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        indicatorColor: colorScheme.secondaryContainer,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.outline,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.surfaceDim,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.primary,
        contentTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.surface,
          fontWeight: FontWeight.w600,
        ),
        showCloseIcon: true,
        elevation: 1,
      ),
      dialogTheme: DialogThemeData(backgroundColor: colorScheme.surfaceContainerLowest),
    );
  }
}
