import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/features/hospital/auth/hospital_login_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<my_user.User?>(
      future: FirebaseAuth.instance.currentUser != null
          ? UserService.getUser(FirebaseAuth.instance.currentUser!.uid)
          : Future.value(null),
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

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: cs.onSurface,
                ),
                onPressed: () {
                  AppTheme.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                  SharedPreferencesHelper.setThemeMode(!isDark);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark? Color(0xFF2A2A2A) : AppColors.lightBorder, width: 3),
                      color: isDark? Color(0xFF1A1A1A) : AppColors.lightSurface,
                    ),
                    child: Icon(Icons.local_hospital, color: isDark? Colors.white24 : AppColors.darkSurface, size: 56),
                  ),
                ),
                const SizedBox(height: 20),
                 Text(
                  user.name ?? "",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async{
                      await FirebaseAuth.instance.signOut();
                      await SharedPreferencesHelper.clear();
                      Navigator.pushReplacementNamed(context, Routes.hospitalLoginRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: AppColors.redDark,
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
          Icon(icon, color: AppColors.redDark, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : AppColors.lightCard,
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      leading: Icon(icon, color: Colors.grey, size: 22),
      title: Text(
        title,
        style: TextStyle(color: cs.onSurface, fontSize: 15),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey.withValues(alpha: 0.5),
        size: 14,
      ),
      onTap: () {},
    );
  }
}
