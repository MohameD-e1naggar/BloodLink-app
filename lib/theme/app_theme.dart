import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية للهوية البصرية
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkBg = Color.fromARGB(
    255,
    0,
    0,
    0,
  ); // الخلفية التي اخترتها
  static const Color darkCard = Color.fromARGB(255, 0, 0, 0);

  // إعدادات الثيم الغامق (Dark)
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        surface: Color.fromARGB(255, 0, 0, 0),
        secondary: primaryRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
      ),
      // تحسين شكل الخطوط في كل التطبيق
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  // إعدادات الثيم الفاتح (Light)
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
    );
  }
}
