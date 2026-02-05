import 'package:flutter/material.dart';

class AppTheme {
  // App's primary teal color
  static const Color primaryTeal = Color(0xFF6AA39B);
  static const Color darkTeal = Color(0xFF4C8077);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.teal,
      primaryColor: primaryTeal,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      cardColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: primaryTeal,
        secondary: darkTeal,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.teal,
      primaryColor: primaryTeal,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: ColorScheme.dark(
        primary: primaryTeal,
        secondary: darkTeal,
        surface: const Color(0xFF1E1E1E),
      ),
    );
  }
}

