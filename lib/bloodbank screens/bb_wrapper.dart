import 'package:flutter/material.dart';
import 'package:www/bloodbank%20screens/bloodbank_home.dart';
import 'package:www/bloodbank%20screens/profile_bb.dart';
import 'package:www/bloodbank%20screens/requestsbb.dart';

class BloodBankWrapper extends StatefulWidget {
  const BloodBankWrapper({super.key});

  @override
  State<BloodBankWrapper> createState() => _BloodBankWrapperState();
}

class _BloodBankWrapperState extends State<BloodBankWrapper> {
  int _currentIndex = 0;

  // القائمة المحدثة بالشاشات الحقيقية
  final List<Widget> _pages = [
    const BloodBankHomeScreen(), // شاشة المخزون (Inventory)
    const BloodBankRequestsScreen(), // شاشة الطلبات (الجديدة)
    BloodBankProfileScreen(), // شاشة البروفايل (التي صممناها سابقاً)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0F0F0F),
          selectedItemColor: const Color.fromARGB(255, 196, 0, 29),
          unselectedItemColor: Colors.grey,
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
