import 'package:flutter/material.dart';
import 'package:www/hospital/requests_screen.dart';
import 'hospital_home.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // الصفحة الافتراضية هي Home

  final List<Widget> _screens = [
    const HomeScreen(),
    const RequestsScreen(), // هنا سيتم عرض صفحة الطلبات عند الضغط على الزر
    const profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack يحافظ على حالة كل صفحة (مثلاً مكان السكرول)
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
          ), // اللون الأحمر للتحديد
          unselectedItemColor: const Color(0xFF555555),
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // تغيير الصفحة بناءً على الـ Index
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
              label: 'REQUESTS', // هذا الزر سيفتح Index 1
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
