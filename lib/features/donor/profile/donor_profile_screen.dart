import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';

class ProfileSettingsScreen extends StatefulWidget {
   ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late String name;
  late String id;
  late my_user.User user;
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
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  'Profile Settings',
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
                    _buildAvatarSection(user.name ?? "", user.id ?? ""),
                    const SizedBox(height: 30),
                    _buildSectionHeader(Icons.person_outline, 'PERSONAL INFO'),
                    _buildInfoCard([
                      _buildInfoTile('Full Name', user.name ?? ""),
                      _buildDivider(),
                      _buildInfoTile('Email Address', user.email ??""),
                      _buildDivider(),
                      _buildInfoTile('Phone Number', user.phoneNumber ??""),
                    ]),
                    const SizedBox(height: 25),
                    _buildSectionHeader(
                      Icons.medical_services_outlined,
                      'MEDICAL INFO',
                    ),
                    _buildInfoCard([
                      _buildInfoTile('Blood Type', user.bloodType ??""),
                      _buildDivider(),
                      _buildInfoTile('Last Donation', user.donorLastDonation ??""),
                      _buildDivider(),
                      _buildInfoTile(
                        'Medical Conditions',
                        "Takes Medication: ${user.takesMedication ??false ?"Yes":"No"}\n"
                            "Had Surgery: ${user.hadSurgery ??false ?"Yes":"No" }\n"
                            "Has Anemia: ${user.hasAnemia ??false ?"Yes":"No" }\n"
                            "Has Chronic Diseases: ${user.hasChronicDiseases ??false ?"Yes":"No" }\n",
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await SharedPreferencesHelper.clear();
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, Routes.donorLoginRoute);
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
      }  Widget _buildAvatarSection(String name,String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  color: AppColors.redDark,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightSurface,
                child: Icon(Icons.person, color: isDark ? Colors.white : Colors.grey, size: 50),
              ),
            ),
            Container(
              height: 35,
              width: 35,
              decoration: const BoxDecoration(
                color: AppColors.redDark,
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
         Text(
          name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
         Text(
          'Donor ID: ${id.substring(0,9)}',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Row(
        children: [
          Icon(icon, color: AppColors.redDark, size: 18),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool isLast = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      color: cs.onSurface.withValues(alpha: 0.05),
      height: 1,
      indent: 15,
      endIndent: 15,
    );
  }
}
