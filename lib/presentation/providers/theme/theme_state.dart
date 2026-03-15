import 'package:flutter/material.dart';

class ThemeState {
  final bool isLight;
  final ThemeData themeData;

  const ThemeState({required this.isLight, required this.themeData});

  ThemeState copyWith({bool? isLight, ThemeData? themeData}) {
    return ThemeState(
      isLight: isLight ?? this.isLight,
      themeData: themeData ?? this.themeData,
    );
  }
}
