import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:www/features/donor/profile/donor_profile_screen.dart';
import 'package:www/features/donor/requests/donor_request_screen.dart';
import 'package:www/features/donor/auth/donor_login_screen.dart';
import 'package:www/features/donor/home/donor_home_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';
import 'package:www/core/services/firestore_service.dart';

class DonorWrapper extends StatefulWidget {
  const DonorWrapper({super.key});

  @override
  State<DonorWrapper> createState() => _DonorWrapperState();
}

class _DonorWrapperState extends State<DonorWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DonorHomeScreen(),
    const MyRequestsScreen(),
     ProfileSettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: lazily reset expired emergency requests on app open
    EmergencyResetService.checkAndResetExpiredCriticalRequests();
  }

  Future<bool> _onWillPop() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Logout',
              style: TextStyle(
                color: AppColors.redDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.donorLoginRoute, (route) => false);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedItemColor: AppColors.redDark,
            unselectedItemColor: cs.onSurface.withValues(alpha: 0.5),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital_outlined),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
