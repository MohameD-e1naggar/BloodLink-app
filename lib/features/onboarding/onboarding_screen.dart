import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:www/features/onboarding/onboarding_content.dart';
import 'package:www/features/onboarding/onboarding_model.dart';
import 'package:www/core/utiles/ThemeManager.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.5,
                colors: _currentPage == 0
                    ? [
                        isDark ? const Color.fromARGB(97, 87, 0, 0) : AppColors.red.withValues(alpha: 0.1),
                        isDark ? const Color.fromARGB(255, 0, 0, 0) : AppColors.lightBg,
                      ]
                    : [
                        isDark ? const Color.fromARGB(255, 0, 0, 0) : AppColors.lightBg,
                        isDark ? const Color.fromARGB(148, 87, 0, 0) : AppColors.red.withValues(alpha: 0.15),
                      ],
              ),
            ),
          ),

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
                      Icon(
                        _onboardingData[index].icon,
                        size: 150,
                        color: AppColors.redDark,
                      ),
                      const SizedBox(height: 60),
                      Text(
                        _onboardingData[index].title,
                        style: TextStyle(
                          color: cs.onSurface,
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
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

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
                  side: BorderSide(color: cs.onSurface.withValues(alpha: 0.2)),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'SKIP',
                  style: TextStyle(color: cs.onSurface, fontSize: 12),
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
            ? AppColors.redDark
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
