import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  /// Make [AppTheme] to be singleton
  static final AppTheme _instance = AppTheme._();

  factory AppTheme() => _instance;

  AppTheme._();

  static late BuildContext _context;

  Color _primaryColor = const Color(0xFF356859);
  Color? _secondaryColor;
  Color? _tertiaryColor;
  Color? _neutralColor;
  Brightness _brightness = Brightness.light;
  TextTheme _primaryTextTheme = GoogleFonts.montserratTextTheme();
  TextTheme _secondaryTextTheme = GoogleFonts.poppinsTextTheme();

  TextTheme get textTheme => Theme.of(_context).textTheme;

  ColorScheme get colorScheme => Theme.of(_context).colorScheme;

  ThemeData init(
    BuildContext context, {
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
    Brightness? brightness,
    TextTheme? primaryTextTheme,
    TextTheme? secondaryTextTheme,
  }) {
    _context = context;
    _primaryColor = primaryColor ?? _primaryColor;
    secondaryColor = secondaryColor;
    tertiaryColor = tertiaryColor;
    neutralColor = neutralColor;
    _brightness = brightness ?? _brightness;
    _primaryTextTheme = primaryTextTheme ?? _primaryTextTheme;
    _secondaryTextTheme = secondaryTextTheme ?? _secondaryTextTheme;

    return _base(
      colorScheme: _scheme().toColorScheme(_brightness),
      brightness: _brightness,
      primaryTextTheme: _primaryTextTheme,
      secondaryTextTheme: _secondaryTextTheme,
    );
  }

  Scheme _scheme() {
    final base = CorePalette.of(_primaryColor.value);

    final primary = base.primary;
    final secondary = _secondaryColor != null ? CorePalette.of(_secondaryColor!.value).primary : base.primary;
    final tertiary = _tertiaryColor != null ? CorePalette.of(_tertiaryColor!.value).primary : base.tertiary;
    final neutral = _neutralColor != null ? CorePalette.of(_neutralColor!.value).neutral : base.neutral;

    return Scheme(
      primary: primary.get(40),
      onPrimary: primary.get(100),
      primaryContainer: primary.get(90),
      onPrimaryContainer: primary.get(10),
      secondary: secondary.get(40),
      onSecondary: secondary.get(100),
      secondaryContainer: secondary.get(90),
      onSecondaryContainer: secondary.get(10),
      tertiary: tertiary.get(40),
      onTertiary: tertiary.get(100),
      tertiaryContainer: tertiary.get(90),
      onTertiaryContainer: tertiary.get(10),
      error: base.error.get(40),
      onError: base.error.get(100),
      errorContainer: base.error.get(90),
      onErrorContainer: base.error.get(10),
      background: neutral.get(99),
      onBackground: neutral.get(10),
      surface: neutral.get(99),
      onSurface: neutral.get(10),
      outline: base.neutralVariant.get(50),
      outlineVariant: base.neutralVariant.get(80),
      surfaceVariant: base.neutralVariant.get(90),
      onSurfaceVariant: base.neutralVariant.get(30),
      shadow: neutral.get(0),
      scrim: neutral.get(0),
      inverseSurface: neutral.get(20),
      inverseOnSurface: neutral.get(95),
      inversePrimary: primary.get(80),
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

    final isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      extensions: [this],
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? _neutralColor : colorScheme.surface,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      tabBarTheme: TabBarTheme(
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
        backgroundColor: isLight ? _neutralColor : colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        indicatorColor: colorScheme.secondaryContainer,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? _neutralColor : colorScheme.surface,
      ),
    );
  }

  @override
  ThemeExtension<AppTheme> copyWith({
    Color? primaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
    Brightness? brightness,
  }) =>
      AppTheme._instance.copyWith(
        primaryColor: primaryColor ?? _primaryColor,
        tertiaryColor: tertiaryColor ?? _tertiaryColor,
        neutralColor: neutralColor ?? _neutralColor,
        brightness: brightness ?? _brightness,
      );

  @override
  AppTheme lerp(
    covariant ThemeExtension<AppTheme>? other,
    double t,
  ) {
    if (other is! AppTheme) return this;

    final theme = AppTheme();

    theme._primaryColor = Color.lerp(_primaryColor, other._primaryColor, t)!;
    theme._tertiaryColor = Color.lerp(_tertiaryColor, other._tertiaryColor, t)!;
    theme._neutralColor = Color.lerp(_neutralColor, other._neutralColor, t)!;

    return theme;
  }
}

extension on Scheme {
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      primary: Color(primary),
      onPrimary: Color(onPrimary),
      primaryContainer: Color(primaryContainer),
      onPrimaryContainer: Color(onPrimaryContainer),
      secondary: Color(secondary),
      onSecondary: Color(onSecondary),
      secondaryContainer: Color(secondaryContainer),
      onSecondaryContainer: Color(onSecondaryContainer),
      tertiary: Color(tertiary),
      onTertiary: Color(onTertiary),
      tertiaryContainer: Color(tertiaryContainer),
      onTertiaryContainer: Color(onTertiaryContainer),
      error: Color(error),
      onError: Color(onError),
      errorContainer: Color(errorContainer),
      onErrorContainer: Color(onErrorContainer),
      outline: Color(outline),
      outlineVariant: Color(outlineVariant),
      surface: Color(surface),
      onSurface: Color(onSurface),
      surfaceContainerHighest: Color(surfaceVariant),
      onSurfaceVariant: Color(onSurfaceVariant),
      inverseSurface: Color(inverseSurface),
      onInverseSurface: Color(inverseOnSurface),
      inversePrimary: Color(inversePrimary),
      shadow: Color(shadow),
      scrim: Color(scrim),
      surfaceTint: Color(primary),
      brightness: brightness,
    );
  }
}
