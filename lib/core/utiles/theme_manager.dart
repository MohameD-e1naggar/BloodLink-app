import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFE53935);
  static const Color redDark = Color(0xFFC4001D);
  static const Color lightBg = Color(0xFFF7F3F3);
  static const Color darkBg = Color(0xFF0F0F0F);
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color lightSurface = Color(0xFFF0EDED);
  static const Color darkSurface = Color(0xFF252525);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF333333);
  static const Color lightOnSurface = Colors.black87;
  static const Color darkOnSurface = Colors.white;
}

class AppTheme {
  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.red,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
        secondary: AppColors.redDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redDark,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.red,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.red,
        surface: AppColors.lightSurface,
        onSurface: Colors.black87,
        secondary: AppColors.redDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redDark,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
