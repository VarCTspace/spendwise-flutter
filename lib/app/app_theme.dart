import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6750A4);
  static const Color background = Color(0xFFF7F6FC);
  static const Color income = Color(0xFF16A36A);
  static const Color expense = Color(0xFFE45B68);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}