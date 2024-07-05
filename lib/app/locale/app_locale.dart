import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App Locale
class AppLocale {
  // This class is not meant to be instatiated or extended; this constructor
  // prevents instantiation and extension.
  AppLocale._();

  static Locale defaultLocale = const Locale('id', 'ID');
  static String defaultPhoneCode = '+62';
  static String defaultCurrencyCode = 'Rp';

  static const List<Locale> supportedLocales = [
    Locale('id', 'ID'),
    Locale('en', 'EN'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
