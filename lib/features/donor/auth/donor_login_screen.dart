import 'package:www/core/utiles/validator_manager.dart';
import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/user_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/features/donor/auth/registration/basic_info_screen.dart';
import 'package:www/features/donor/donor_wrapper.dart';
import 'package:www/features/onboarding/role_selection_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class DonorLoginScreen extends StatefulWidget {
  const DonorLoginScreen({super.key});

  @override
  State<DonorLoginScreen> createState() => _DonorLoginScreenState();
}

class _DonorLoginScreenState extends State<DonorLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, Routes.roleSelectionRoute);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: cs.onSurface,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.lightCard,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Welcome back! Please enter your details.",
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildLabel("Email Address"),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: _emailController,
                    hint: "example@mail.com",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 30),
                  _buildLabel("Password"),
                  const SizedBox(height: 12),
                  _buildTextFormField(
                    controller: _passwordController,
                    validator: ValidatorManager.validatePassword,
                  hint: "••••••••",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [AppColors.red, AppColors.redDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.red.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          login();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New user? ",
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.donorRegisterBasicRoute);
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: AppColors.redDark,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  void login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        final userDoc = await UserService.getUser(credential.user!.uid);
        if (userDoc == null || userDoc.type != my_user.UserTypes.donor.name) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access Denied. You are not registered as a Donor. Please use the correct portal.')),
            );
          }
          return;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.donorHomeRoute);
        }
      }

    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
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
        setState(() {
          _isLoading = false;
        });
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
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        validator: validator,
        style: TextStyle(color: cs.onSurface, fontSize: 15),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: AppColors.redDark, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
