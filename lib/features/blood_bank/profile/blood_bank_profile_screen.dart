import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/features/blood_bank/auth/blood_bank_login_screen.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';

class BloodBankProfileScreen extends StatelessWidget {

  const BloodBankProfileScreen({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Blood Bank Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            centerTitle: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
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
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightSurface,
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
                  user.name ?? "",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
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

                _buildSectionTitle('BLOOD BANK INFO'),
                _buildInfoCard([
                  _buildInfoTile(
                    Icons.email,
                    'EMAIL ADDRESS',
                    user.email ?? "",
                    context,
                  ),
                  _buildDivider(context),
                  _buildInfoTile(
                    Icons.phone,
                    'CONTACT NUMBER',
                    user.phoneNumber ?? "",
                    context,
                  ),
                ], context),

                const SizedBox(height: 24),

                _buildSectionTitle('RESPONSIBLE PERSON'),
                _buildInfoCard([
                  _buildInfoTile(Icons.person, 'FULL NAME', user.adminName ?? "", context),
                  _buildDivider(context),
                  _buildInfoTile(Icons.badge, 'MEDICAL ID', user.adminNationalId ?? "", context),
                  _buildDivider(context),
                  _buildInfoTile(
                    Icons.smartphone,
                    'DIRECT PHONE',
                    user.adminPhoneNumber ?? "",
                    context,
                  ),
                ], context),

                const SizedBox(height: 24),

                _buildSectionTitle('LOCATION'),
                _buildInfoCard([
                  _buildInfoTile(
                    Icons.location_on,
                    'ADDRESS',
                    user.address ?? "",
                    context,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A1515) : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: Icon(Icons.map_outlined, color: Colors.grey, size: 36),
                    ),
                  ),
                ], context),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await SharedPreferencesHelper.clear();
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, Routes.bloodBankLoginRoute);
                      }
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.redDark,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A1515) : AppColors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.redDark,
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
                style: TextStyle(
                  color: cs.onSurface,
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

  Widget _buildDivider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: cs.onSurface.withValues(alpha: 0.1), thickness: 0.5, indent: 45),
    );
  }
}
