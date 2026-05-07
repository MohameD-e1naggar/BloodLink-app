import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:www/features/donor/auth/donor_login_screen.dart';
import 'package:www/features/hospital/auth/hospital_login_screen.dart';

import 'package:www/features/blood_bank/auth/blood_bank_login_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: cs.onSurface,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.lightCard,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Welcome to\nBloodLink",
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Please select your role to continue",
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 50),

                _buildRoleCard(
                  context,
                  title: "Donor",
                  subtitle: "Search for blood or donate to others",
                  icon: Icons.person_search_rounded,
                  onTap: () => Navigator.pushNamed(context, Routes.donorLoginRoute),
                ),
                const SizedBox(height: 20),

                _buildRoleCard(
                  context,
                  title: "Hospital",
                  subtitle: "Request blood units for patients",
                  icon: Icons.local_hospital_rounded,
                  onTap: () => Navigator.pushNamed(context, Routes.hospitalLoginRoute),
                ),
                const SizedBox(height: 20),

                _buildRoleCard(
                  context,
                  title: "Blood Bank",
                  subtitle: "Manage inventory and donations",
                  icon: Icons.inventory_2_rounded,
                  onTap: () => Navigator.pushNamed(context, Routes.bloodBankLoginRoute),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.redDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.redDark,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: cs.onSurface.withValues(alpha: 0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
