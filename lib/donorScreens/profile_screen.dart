import 'package:flutter/material.dart';
// لا نحتاج Navigator.pushAndRemoveUntil هنا - الـ wrapper بيتحكم في الرجوع

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // إزالة زر الرجوع - الـ BottomNav بيتحكم
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color.fromARGB(255, 196, 0, 29),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatarSection(),
            const SizedBox(height: 30),
            _buildSectionHeader(Icons.person_outline, 'PERSONAL INFO'),
            _buildInfoCard([
              _buildInfoTile('Full Name', 'Mohamed Ehab Mohamed Shaaban'),
              _buildDivider(),
              _buildInfoTile('Email Address', 'Mohamedehab9922@gmail.com'),
              _buildDivider(),
              _buildInfoTile('Phone Number', '+201234567890'),
            ]),
            const SizedBox(height: 25),
            _buildSectionHeader(
              Icons.medical_services_outlined,
              'MEDICAL INFO',
            ),
            _buildInfoCard([
              _buildInfoTile('Blood Type', 'O Positive (O+)'),
              _buildDivider(),
              _buildInfoTile('Last Donation', 'Oct 12, 2023'),
              _buildDivider(),
              _buildInfoTile(
                'Medical Conditions',
                'None reported',
                isLast: true,
              ),
            ]),
            const SizedBox(height: 25),
            _buildSectionHeader(Icons.location_on_outlined, 'LOCATION'),
            _buildInfoCard([
              const ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                title: Text(
                  'Preferred Donation Center',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                subtitle: Text(
                  'Al-Maadi Blood Bank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.map_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 196, 0, 29),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundColor: Color.fromARGB(118, 37, 37, 37),
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
            ),
            Container(
              height: 35,
              width: 35,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 196, 0, 29),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          'Mohamed Ehab',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Donor ID: BL-8829',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 196, 0, 29), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(118, 37, 37, 37),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      height: 1,
      indent: 15,
      endIndent: 15,
    );
  }
}
