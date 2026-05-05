import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/features/blood_bank/auth/blood_bank_login_screen.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';
import 'package:www/core/utiles/ValidatorManager.dart';

class BloodBankProfileScreen extends StatefulWidget {
  const BloodBankProfileScreen({super.key});

  @override
  State<BloodBankProfileScreen> createState() => _BloodBankProfileScreenState();
}

class _BloodBankProfileScreenState extends State<BloodBankProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser != null
          ? UserService.getUser(FirebaseAuth.instance.currentUser!.uid)
          : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData) {
          return const Text("No user found");
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
                          child: const Text(
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

                _buildSectionTitle('ACCOUNT SETTINGS'),
                _buildInfoCard([
                  _buildActionTile(Icons.edit_outlined, 'Edit Profile', () => _showEditProfileDialog(user)),
                  _buildDivider(context),
                  _buildActionTile(Icons.lock_outline, 'Change Password', () => _showChangePasswordDialog()),
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
                    child: const Center(
                      child: Icon(Icons.map_outlined, color: Colors.grey, size: 36),
                    ),
                  ),
                ], context),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await SharedPreferencesHelper.removeKey(SharedPreferencesHelper.userKey);
                      await SharedPreferencesHelper.removeKey(SharedPreferencesHelper.reqsKey);
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
      },
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

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
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
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(my_user.User user) {
    final nameController = TextEditingController(text: user.name);
    final addressController = TextEditingController(text: user.address);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final adminNameController = TextEditingController(text: user.adminName);
    final adminPhoneController = TextEditingController(text: user.adminPhoneNumber);
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Edit Profile", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  _buildTextField(nameController, "Bank Name", Icons.business, ValidatorManager.validateName),
                  const SizedBox(height: 15),
                  _buildTextField(addressController, "Address", Icons.location_on, ValidatorManager.validateAddress),
                  const SizedBox(height: 15),
                  _buildTextField(phoneController, "Contact Phone", Icons.phone, ValidatorManager.validatePhoneNumber),
                  const SizedBox(height: 15),
                  _buildTextField(adminNameController, "Admin Name", Icons.person, ValidatorManager.validateName),
                  const SizedBox(height: 15),
                  _buildTextField(adminPhoneController, "Admin Phone", Icons.smartphone, ValidatorManager.validatePhoneNumber),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await UserService.updateUser(user.id!, {
                          'name': nameController.text,
                          'address': addressController.text,
                          'phoneNumber': phoneController.text,
                          'adminName': adminNameController.text,
                          'adminPhoneNumber': adminPhoneController.text,
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
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
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

  Widget _buildDivider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: cs.onSurface.withValues(alpha: 0.1), thickness: 0.5, indent: 45),
    );
  }
}
