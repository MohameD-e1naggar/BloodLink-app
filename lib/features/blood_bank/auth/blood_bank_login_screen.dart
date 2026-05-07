import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/user_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/validator_manager.dart';
import 'package:www/features/blood_bank/blood_bank_wrapper.dart';
import 'package:www/features/blood_bank/auth/registration/blood_bank_registration_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class BloodBankLoginScreen extends StatefulWidget {

  const BloodBankLoginScreen({super.key});

  @override
  State<BloodBankLoginScreen> createState() => _BloodBankLoginScreenState();
}

class _BloodBankLoginScreenState extends State<BloodBankLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: cs.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.roleSelectionRoute),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Icon(
                    Icons.science,
                    color: AppColors.redDark,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "BLOOD BANK LOGIN",
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildLabel("Email Address"),
                const SizedBox(height: 8),
                _buildTextField(
                  validator: ValidatorManager.validateEmail,
                  controller: _emailController,
                  hint: "bloodbank@example.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _buildLabel("Password"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  validator: ValidatorManager.validatePassword,
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.redDark.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New provider? ",
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.bloodBankRegisterRoute);
                      },
                      child: const Text(
                        "Register Now",
                        style: TextStyle(
                          color: AppColors.redDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        final userDoc = await UserService.getUser(credential.user!.uid);
        if (userDoc == null || userDoc.type != my_user.UserTypes.bloodBank.name) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access Denied. You are not registered as a Blood Bank.')),
            );
          }
          return;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.bloodBankHomeRoute);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'user-not-found') {
        message = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final TextEditingController resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Reset Password', style: TextStyle(color: cs.onSurface)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter your email address to receive a password reset link.',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: TextFormField(
                    controller: resetEmailController,
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      hintText: "Email address",
                      hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isResetting ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isResetting
                    ? null
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your email')),
                          );
                          return;
                        }

                        setDialogState(() => isResetting = true);

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password reset link sent to your email!')),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String msg = 'Failed to send reset email';
                          if (e.code == 'user-not-found' || e.code == 'invalid-credential') msg = 'No user found for that email';
                          if (e.code == 'invalid-email') msg = 'Invalid email format';

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() => isResetting = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redDark,
                ),
                child: isResetting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Send Link', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        color: cs.onSurface.withValues(alpha: 0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14),
        prefixIcon: Icon(icon, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1414) : AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
