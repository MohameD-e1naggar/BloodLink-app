import 'package:www/core/utiles/ValidatorManager.dart';
import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:www/features/hospital/auth/hospital_login_screen.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';

class HospitalResponsiblePersonScreen extends StatefulWidget {
  final String hospitalName;
  final String email;
  final String pass;
  final String phoneNumber;
  final String address;
  const HospitalResponsiblePersonScreen({
    super.key,
    required this.phoneNumber,
    required this.hospitalName,
    required this.email,
    required this.pass,
    required this.address,
  });

  @override
  State<HospitalResponsiblePersonScreen> createState() =>
      _HospitalResponsiblePersonScreenState();
}

class _HospitalResponsiblePersonScreenState extends State<HospitalResponsiblePersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _adminNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  String _adminPhoneNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _adminNameController.dispose();
    _nationalIdController.dispose();
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
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.redDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'MedRegistry',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REGISTRATION PROGRESS',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.38),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Step 2 of 3',
                      style: TextStyle(
                        color: AppColors.redDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.66,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.redDark,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Responsible Person',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Details of the hospital administrator',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.54), fontSize: 14),
                ),
                const SizedBox(height: 32),

                _buildFieldLabel('Responsible Person Name', context),
                _buildTextField(
                  controller: _adminNameController,
                  hint: 'Enter full name',
                  validator: ValidatorManager.validateName,
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('National ID of Responsible Person', context),
                _buildTextField(
                  controller: _nationalIdController,
                  hint: 'ID Number (e.g. 123456789)',
                  keyboardType: TextInputType.number,
                  validator: ValidatorManager.validateNationalId,
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('Phone Number of Responsible Person', context),
                IntlPhoneField(
                  initialCountryCode: 'EG',
                  dropdownTextStyle: TextStyle(color: cs.onSurface),
                  style: TextStyle(color: cs.onSurface),
                  cursorColor: AppColors.redDark,
                  languageCode: "en",
                  onChanged: (phone) =>
                      _adminPhoneNumber = phone.completeNumber,
                  decoration: _inputDecoration(hint: '(555) 000-0000', context: context),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_formKey.currentState!.validate()) {
                        if (_adminPhoneNumber.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter phone number'),
                            ),
                          );
                          return;
                        }
                        _createAccount();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.7),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: cs.onSurface, fontSize: 15),
      decoration: _inputDecoration(hint: hint, context: context),
    );
  }

  InputDecoration _inputDecoration({required String hint, required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.24), fontSize: 14),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1414) : AppColors.lightCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: isDark ? BorderSide.none : BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.redDark,
          width: 1.5,
        ),
      ),
    );
  }

  void _createAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.pass,
      );
      final uid = credential.user!.uid;
      await UserService.createUser(my_user.User(
        id: uid,
        email: widget.email,
        name: widget.hospitalName,
        phoneNumber: widget.phoneNumber,
        adminName: _adminNameController.text.trim(),
        adminNationalId: _nationalIdController.text.trim(),
        adminPhoneNumber: _adminPhoneNumber.trim(),
        address: widget.address,
        type: my_user.UserTypes.hospital.name,
      ));

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.hospitalLoginRoute, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'An error occurred';
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
