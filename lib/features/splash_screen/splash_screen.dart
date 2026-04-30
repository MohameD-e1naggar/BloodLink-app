import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:www/features/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.onboardingRoute, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.0,
            colors: [
              Color(0xFF4A0000),
              Colors.black,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlowingBloodIcon(),
            const SizedBox(height: 40),
            const Text(
              'Blood Link',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Save Lives Faster',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingBloodIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFE53935,
            ).withValues(alpha: 0.4),
            blurRadius: 80,
            spreadRadius: 15,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1414),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: const Color.fromARGB(255, 196, 0, 29).withValues(alpha: 0.1),
          ),
        ),
        child: Image.asset(
          'assets/blood_3728510.png',
          width: 90,
          height: 90,
        ),
      ),
    );
  }
}
