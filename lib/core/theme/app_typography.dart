import 'package:flutter/material.dart';

abstract final class AppTypography {
  // Set fontFamily here after registering your Arabic/Latin font in pubspec.
  static const textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(fontSize: 14, height: 1.6),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );
}
