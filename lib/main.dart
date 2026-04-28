import 'package:flutter/material.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPref.init();

   runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // دالة ذكية لتغيير الثيم من أي مكان في التطبيق
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // الحالة الافتراضية
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      setState(() => _themeMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloodLink',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,

      home: const SplashScreen(),
    );
  }
}
