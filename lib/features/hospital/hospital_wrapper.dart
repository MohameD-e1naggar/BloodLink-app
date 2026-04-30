import 'package:flutter/material.dart';
import 'package:www/features/hospital/requests/hospital_requests_screen.dart';
import 'package:www/features/hospital/home/hospital_home_screen.dart';
import 'package:www/features/hospital/profile/hospital_profile_screen.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color.fromARGB(
            255,
            196,
            0,
            29,
          ),
          unselectedItemColor: const Color(0xFF555555),
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
