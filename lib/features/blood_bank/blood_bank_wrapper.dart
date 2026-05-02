import 'package:flutter/material.dart';
import 'package:www/features/blood_bank/home/blood_bank_home_screen.dart';
import 'package:www/features/blood_bank/profile/blood_bank_profile_screen.dart';
import 'package:www/features/blood_bank/requests/blood_bank_requests_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';
import 'package:www/core/services/firestore_service.dart';

class BloodBankWrapper extends StatefulWidget {
  const BloodBankWrapper({super.key});

  @override
  State<BloodBankWrapper> createState() => _BloodBankWrapperState();
}

class _BloodBankWrapperState extends State<BloodBankWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BloodBankHomeScreen(),
    const BloodBankRequestsScreen(),
    BloodBankProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: lazily reset expired emergency requests on app open
    EmergencyResetService.checkAndResetExpiredCriticalRequests();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: AppColors.redDark,
          unselectedItemColor: cs.onSurface.withValues(alpha: 0.5),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'HOME',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'REQUESTS'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}
