import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/theme_manager.dart';
import 'package:www/core/utiles/validator_manager.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<my_user.User?>(
      future: FirebaseAuth.instance.currentUser != null
          ? UserService.getUser(FirebaseAuth.instance.currentUser!.uid)
          : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No user found"));
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
                  _buildInfoTile('Email Address', user.email ?? ""),
                  _buildDivider(),
                  _buildInfoTile('Phone Number', user.phoneNumber ?? ""),
                ]),
                const SizedBox(height: 25),
                _buildSectionHeader(Icons.medical_services_outlined, 'MEDICAL INFO'),
                _buildInfoCard([
                  _buildInfoTile('Blood Type', user.bloodType ?? ""),
                  _buildDivider(),
                  _buildInfoTile('Last Donation', user.donorLastDonation ?? ""),
                  _buildDivider(),
                  _buildInfoTile(
                    'Medical Conditions',
                    "Takes Medication: ${user.takesMedication ?? false ? "Yes" : "No"}\n"
                        "Had Surgery: ${user.hadSurgery ?? false ? "Yes" : "No"}\n"
                        "Has Anemia: ${user.hasAnemia ?? false ? "Yes" : "No"}\n"
                        "Has Chronic Diseases: ${user.hasChronicDiseases ?? false ? "Yes" : "No"}",
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 25),
                _buildSectionHeader(Icons.settings_outlined, 'ACCOUNT SETTINGS'),
                _buildInfoCard([
                  _buildActionTile(Icons.edit_outlined, 'Edit Profile', () => _showEditProfileDialog(user)),
                  _buildDivider(),
                  _buildActionTile(Icons.lock_outline, 'Change Password', () => _showChangePasswordDialog()),
                ]),
                const SizedBox(height: 25),
                _buildSectionHeader(Icons.location_on_outlined, 'LOCATION'),
                _buildInfoCard([
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    title: const Text(
                      'Preferred Donation Center',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    subtitle: Text(
                      'Al-Maadi Blood Bank',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.map_outlined, color: Colors.grey, size: 20),
                  ),
                ]),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await SharedPreferencesHelper.removeKey(SharedPreferencesHelper.userKey);
                      await SharedPreferencesHelper.removeKey(SharedPreferencesHelper.reqsKey);
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
      },
    );
  }

  Widget _buildAvatarSection(String name, String id) {
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
                border: Border.all(color: AppColors.redDark, width: 2),
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
              decoration: const BoxDecoration(color: AppColors.redDark, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
        Text(
          'Donor ID: ${id.length > 9 ? id.substring(0, 9) : id}',
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

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      leading: Icon(icon, color: Colors.grey, size: 22),
      title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.withValues(alpha: 0.5), size: 14),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(my_user.User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                Text("Edit Profile", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                _buildTextField(nameController, "Full Name", Icons.person, ValidatorManager.validateName),
                const SizedBox(height: 15),
                _buildTextField(phoneController, "Phone Number", Icons.phone, ValidatorManager.validatePhoneNumber),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await UserService.updateUser(user.id!, {
                        'name': nameController.text,
                        'phoneNumber': phoneController.text,
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        setState(() {});
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redDark,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                Text("Change Password", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                _buildTextField(currentPasswordController, "Current Password", Icons.lock_outline, ValidatorManager.validatePassword, isPassword: true),
                const SizedBox(height: 15),
                _buildTextField(newPasswordController, "New Password", Icons.lock, ValidatorManager.validatePassword, isPassword: true),
                const SizedBox(height: 15),
                _buildTextField(confirmPasswordController, "Confirm New Password", Icons.lock_reset, (val) => ValidatorManager.validateConfirmPassword(val, newPasswordController.text), isPassword: true),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        User? user = FirebaseAuth.instance.currentUser;
                        AuthCredential credential = EmailAuthProvider.credential(email: user!.email!, password: currentPasswordController.text);
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newPasswordController.text);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Password updated successfully")),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redDark,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Change Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? Function(String?)? validator, {bool isPassword = false}) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.redDark, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.redDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
