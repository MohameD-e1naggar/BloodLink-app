import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/Backend/models/User.dart' as my_user;

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<my_user.User?>(
      future: SharedPref.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData) {
          return Text("No user found");
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F0F),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // صورة المستشفى
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2A2A2A), width: 3),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                 Text(
                  user.name ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Healthcare Provider",
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionTitle(Icons.business_outlined, "HOSPITAL DETAILS"),
                _buildInfoTile(
                  Icons.location_on_outlined,
                  "Location",
                 user.address ?? "",
                ),
                _buildInfoTile(Icons.badge_outlined, "License ID", "HOSP-${user.id?.substring(0,9)}"),
                _buildInfoTile(
                  Icons.phone_outlined,
                  "Emergency Line",
                  user.phoneNumber ?? "",
                ),

                const SizedBox(height: 20),
                _buildSectionTitle(Icons.settings_outlined, "ACCOUNT SETTINGS"),
                _buildActionTile(Icons.edit_outlined, "Edit Profile"),
                _buildActionTile(Icons.lock_outline, "Change Password"),

                const SizedBox(height: 40),
                // زر تسجيل الخروج
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async{
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
                      ),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 196, 0, 29),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 196, 0, 29), size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
              ),
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
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white12,
        size: 14,
      ),
      onTap: () {},
    );
  }
}
