import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:www/bloodbank%20screens/responsible_persion_screen.dart';

class bloodbank_registration extends StatefulWidget {
  const bloodbank_registration({super.key});

  @override
  State<bloodbank_registration> createState() => _bloodbank_registrationState();
}

class _bloodbank_registrationState extends State<bloodbank_registration> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _phoneNumber = '';
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF120808) : Colors.white,
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
                    color: isDarkMode ? Colors.white : Colors.black,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bloodbank name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Official Email',
                  hint: 'admin@bloodbank.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  isDark: isDarkMode,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  'BloodBank Phone Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  initialCountryCode: 'EG',
                  dropdownTextStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  cursorColor: const Color.fromARGB(255, 196, 0, 29),
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
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  icon: Icons.history,
                  controller: _confirmPasswordController,
                  isDark: isDarkMode,
                  isPassword: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
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

  // --- التعديل الأساسي هنا في زر الانتقال ---
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

            // كود الانتقال للشاشة الثانية
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResponsiblePersonScreenbb(),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 196, 0, 29),
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

  // دالة مساعدة لتنسيق حقل الهاتف
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
      fillColor: isDark ? const Color(0xFF1E1414) : Colors.white,
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
          color: const Color.fromARGB(255, 196, 0, 29),
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
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'MedRegistry',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 196, 0, 29),
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
              'STEP 1 OF 3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 196, 0, 29),
              ),
            ),
            Text(
              '33% Complete',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.33,
          backgroundColor: isDark ? Colors.white10 : Colors.black12,
          valueColor: const AlwaysStoppedAnimation<Color>(
            const Color.fromARGB(255, 196, 0, 29),
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
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
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
            fillColor: isDark ? const Color(0xFF1E1414) : Colors.white,
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
                color: const Color.fromARGB(255, 196, 0, 29),
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
              color: const Color.fromARGB(255, 196, 0, 29),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
