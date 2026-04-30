
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/routes.dart';
import 'core/utiles/ThemeManager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloodLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      initialRoute: Routes.welcomeRoute,
      onGenerateRoute: RouteGenerator.getRoute,
    );
  }
}
