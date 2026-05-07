
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/routes.dart';
import 'core/utiles/theme_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'BloodLink',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: currentMode,
          initialRoute: Routes.welcomeRoute,
          onGenerateRoute: RouteGenerator.getRoute,
        );
      },
    );
  }
}
