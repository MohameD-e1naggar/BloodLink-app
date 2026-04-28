import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/bloodbank%20screens/bloodbank_login.dart';
import '../Backend/models/User.dart' as my_user;

class BloodBankProfileScreen extends StatelessWidget {
  final my_user.User? user;
  
  BloodBankProfileScreen({super.key}) : user = SharedPref.getUser();

  @override
  Widget build(BuildContext context) {
    // Handle null user case
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'User data not available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: ()async{
              await SharedPref.clear();
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder:(context)=> BloodBank_Login(isAdmin: false,)));

            },
            icon: Icon(Icons.logout)),
        title: const Text(
          'Blood Bank Profile',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // صورة البروفايل مع الدائرة الحمراء
            Center(
              child: Stack(
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
                      radius: 50,
                      backgroundColor: Color(0xFF1A1A1A),
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFFE53935),
                    child: Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
             Text(
              user?.name ?? "",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                const SizedBox(width: 8),
                Text(
                  "ACTIVE ORGANIZATION",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // BLOOD BANK INFO Section
            _buildSectionTitle('BLOOD BANK INFO'),
            _buildInfoCard([
              _buildInfoTile(
                Icons.email,
                'EMAIL ADDRESS',
                user?.email ?? "",
              ),
              _buildDivider(),
              _buildInfoTile(
                Icons.phone,
                'CONTACT NUMBER',
                user?.phoneNumber ?? "",
              ),
            ]),

            const SizedBox(height: 24),

            // RESPONSIBLE PERSON Section
            _buildSectionTitle('RESPONSIBLE PERSON'),
            _buildInfoCard([
              _buildInfoTile(Icons.person, 'FULL NAME', user?.adminName ?? ""),
              _buildDivider(),
              _buildInfoTile(Icons.badge, 'MEDICAL ID', user?.adminNationalId ?? ""),
              _buildDivider(),
              _buildInfoTile(
                Icons.smartphone,
                'DIRECT PHONE',
                user?.adminPhoneNumber ?? "",
              ),
            ]),

            const SizedBox(height: 24),

            // LOCATION Section
            _buildSectionTitle('LOCATION'),
            _buildInfoCard([
              _buildInfoTile(
                Icons.location_on,
                'ADDRESS',
                user?.address ?? "",
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://via.placeholder.com/400x120',
                    ), // استبدلها بصورة الخريطة
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1515),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 196, 0, 29),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Colors.grey[800], thickness: 0.5, indent: 45),
    );
  }
}
