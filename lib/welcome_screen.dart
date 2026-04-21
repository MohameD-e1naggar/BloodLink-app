import 'package:flutter/material.dart';
import 'dart:async';

import 'package:www/startingScreens/OnboardingScreen.dart';

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
    // استنى 3 ثواني وانقل لوحدك
    Timer(const Duration(seconds: 3), () {
      // التأمين عشان البرنامج ميقفش لو المستخدم قفل الشاشة
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false, // مسح الـ Splash من الذاكرة تماماً
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // الخلفية المتدرجة اللي في الصورة اللي بعتها
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5), // مكان التوهج (فوق النص)
            radius: 1.0,
            colors: [
              Color(0xFF4A0000), // أحمر غامق جداً
              Colors.black, // بينتهي بأسود صافي
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. أيقونة قطرة الدم الجاهزة مع الـ Glow
            _buildGlowingBloodIcon(),
            const SizedBox(height: 40),
            // 2. النص الأساسي (Blood Link)
            const Text(
              'Blood Link',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5, // مسافة بسيطة بين الحروف لشكل احترافي
              ),
            ),
            const SizedBox(height: 10),
            // 3. النص الفرعي (Save Lives Faster)
            const Text(
              'Save Lives Faster',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70, // أبيض شفاف قليلاً
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
      // التوهج (Glow) اللي ورا الأيقونة
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFE53935,
            ).withValues(alpha: 0.4), // قللنا الـ alpha شوية عشان الصورة ملونة
            blurRadius: 80,
            spreadRadius: 15,
          ),
        ],
      ),
      // الحاوية اللي فيها الصورة
      child: Container(
        padding: const EdgeInsets.all(20), // مساحة داخلية حول الصورة
        decoration: BoxDecoration(
          color: const Color(0xFF1E1414),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: const Color.fromARGB(255, 196, 0, 29).withValues(alpha: 0.1),
          ),
        ),
        child: Image.asset(
          'assets/blood_3728510.png', // مسار الصورة بتاعتك
          width: 90, // اتحكم في الحجم من هنا
          height: 90,
        ),
      ),
    );
  }
}
