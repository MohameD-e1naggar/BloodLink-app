import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:www/startingScreens/OnboardingContent.dart';
import 'package:www/startingScreens/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _onboardingData = [
    OnboardingModel(
      title: 'SAVE LIVES',
      description:
          'Your contribution can be the heartbeat of someone else\'s survival.',
      icon: Icons.monitor_heart_outlined,
    ),
    OnboardingModel(
      title: 'QUICK ACCESS',
      description:
          'Locate the nearest blood drive and manage appointments in seconds.',
      icon: Icons.flash_on_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. الخلفية المتحركة (تدرج لوني يتغير مع الصفحة)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.5,
                colors: _currentPage == 0
                    ? [
                        const Color.fromARGB(97, 87, 0, 0),
                        const Color.fromARGB(255, 0, 0, 0),
                      ]
                    : [
                        const Color.fromARGB(255, 0, 0, 0),
                        const Color.fromARGB(148, 87, 0, 0),
                      ],
              ),
            ),
          ),

          // 2. المحتوى
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _onboardingData.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة ضخمة بتأثير الـ Neon
                    Icon(
                      _onboardingData[index].icon,
                      size: 150,
                      color: const Color.fromARGB(255, 255, 4, 0),
                    ),
                    const SizedBox(height: 60),
                    // النصوص بتصميم فخم
                    Text(
                      _onboardingData[index].title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _onboardingData[index].description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 3. التحكم السفلي (النقط والزرار)
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (i) => _buildDot(i),
                  ),
                ),
                const SizedBox(height: 30),
                OnboardingContent(
                  isLastPage: _currentPage == _onboardingData.length - 1,
                ),
              ],
            ),
          ),

          // 4. زر التخطي (Skip) بشكل جديد
          if (_currentPage != _onboardingData.length - 1)
            Positioned(
              top: 60,
              right: 20,
              child: OutlinedButton(
                onPressed: () => _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: StadiumBorder(),
                ),
                child: const Text(
                  'SKIP',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 4,
      width: _currentPage == index ? 30 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color.fromARGB(255, 196, 0, 29)
            : Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
