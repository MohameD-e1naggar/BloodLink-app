import 'package:www/core/utiles/ValidatorManager.dart';
import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:www/features/blood_bank/auth/registration/blood_bank_responsible_person_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';

class BloodBankRegistrationScreen extends StatefulWidget {
  const BloodBankRegistrationScreen({super.key});

  @override
  State<BloodBankRegistrationScreen> createState() => _BloodBankRegistrationScreenState();
}

class _BloodBankRegistrationScreenState extends State<BloodBankRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _fromHourController = TextEditingController();
  final _toHourController = TextEditingController();

  String _phoneNumber = '';
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
     _fromHourController.dispose();
     _toHourController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(isDark: isDarkMode),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(isDark: isDarkMode),
                const SizedBox(height: 32),
                Text(
                  'Blood Bank Registration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create your bloodbank account to start managing blood requests.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                _buildInputField(
                  label: 'Blood Bank Name',
                  hint: 'Enter full bloodbank name',
                  icon: Icons.business,
                  controller: _nameController,
                  isDark: isDarkMode,
                  validator: ValidatorManager.validateName,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Official Email',
                  hint: 'admin@bloodbank.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  isDark: isDarkMode,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidatorManager.validateEmail,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Address',
                  hint: 'Road 9, Maadi, Cairo',
                  icon: Icons.location_on_outlined,
                  controller: _addressController,
                  isDark: isDarkMode,
                  keyboardType: TextInputType.streetAddress,
                     validator: ValidatorManager.validateAddress,

                ),
                const SizedBox(height: 20),
                Text("Working Hours"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'From',
                        hint: 'e.g. 2',
                        icon: Icons.access_time,
                        controller: _fromHourController,
                        isDark: isDarkMode,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'To',
                        hint: 'e.g. 4',
                        icon: Icons.access_time_filled,
                        controller: _toHourController,
                        isDark: isDarkMode,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'BloodBank Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  initialCountryCode: 'EG',
                  dropdownTextStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: AppColors.redDark,
                  onChanged: (phone) => _phoneNumber = phone.completeNumber,
                  decoration: _inputDecoration(
                    isDark: isDarkMode,
                    hint: 'Phone Number',
                  ),
                ),
                const SizedBox(height: 10),

                _buildInputField(
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isDark: isDarkMode,
                  isPassword: true,
                  validator: ValidatorManager.validatePassword,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  icon: Icons.history,
                  controller: _confirmPasswordController,
                  isDark: isDarkMode,
                  isPassword: true,
                  validator: (val) => ValidatorManager.validateConfirmPassword(val, _passwordController.text),
                ),
                const SizedBox(height: 40),

                _buildNextButton(),
                const SizedBox(height: 24),

                _buildLoginFooter(isDark: isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_phoneNumber.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid phone number'),
                ),
              );
              return;
            }

            Navigator.pushNamed(
              context,
              Routes.bloodBankRegisterResponsibleRoute,
              arguments: {
                'bankName': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'pass': _passwordController.text.trim(),
                'phoneNumber': _phoneNumber.trim(),
                'address': _addressController.text.trim(),
                'workingHours': "${_fromHourController.text.trim()} - ${_toHourController.text.trim()}",
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Next Step',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.grey.shade400,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1414) : AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
                width: 1.2,
              ),
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

  PreferredSizeWidget _buildAppBar({required bool isDark}) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'MedRegistry',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.redDark,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressHeader({required bool isDark}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'STEP 1 OF 2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.redDark,
              ),
            ),
            Text(
              '50% Complete',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.50,
          backgroundColor: isDark ? Colors.white10 : Colors.black12,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.redDark,
          ),
          borderRadius: BorderRadius.circular(5),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDark,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
              size: 19,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1414) : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: isDark
                  ? BorderSide.none
                  : BorderSide(
                      color: Colors.black.withValues(alpha: 0.06),
                      width: 1.2,
                    ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.redDark,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFooter({required bool isDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Log in',
            style: TextStyle(
              color: AppColors.redDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
