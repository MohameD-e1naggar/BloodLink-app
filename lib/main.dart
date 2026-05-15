import 'package:flutter/material.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:www/core/firebase_options.dart';
import 'package:www/core/utiles/theme_manager.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesHelper.init();
  bool isDark = SharedPreferencesHelper.getThemeMode();
  AppTheme.themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(MyApp());
}
