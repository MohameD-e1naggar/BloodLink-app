import 'package:flutter/material.dart';
import 'package:www/features/hospital/requests/hospital_requests_screen.dart';
import 'package:www/features/hospital/home/hospital_home_screen.dart';
import 'package:www/features/hospital/profile/hospital_profile_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';
import 'package:www/core/services/firestore_service.dart';

class HospitalWrapper extends StatefulWidget {
  const HospitalWrapper({super.key});

  @override
  State<HospitalWrapper> createState() => _HospitalWrapperState();
}

class _HospitalWrapperState extends State<HospitalWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HospitalHomeScreen(),
    const RequestsScreen(),
   const profile(),
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
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1))),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.redDark,
          unselectedItemColor: cs.onSurface.withValues(alpha: 0.5),
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'REQUESTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
