import 'package:flutter/material.dart';
import 'package:www/startingScreens/role_selection_screen.dart';

class OnboardingContent extends StatelessWidget {
  final bool isLastPage;

  const OnboardingContent({super.key, required this.isLastPage});

  @override
  Widget build(BuildContext context) {
    return isLastPage
        ? Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 196, 0, 29).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'START JOURNEY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          )
        : const SizedBox(height: 60);
  }
}
