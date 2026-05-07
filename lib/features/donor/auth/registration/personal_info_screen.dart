import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:www/features/donor/auth/registration/health_screening_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String pass;

  const PersonalInfoScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.pass,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? _selectedGender;
  String? _selectedBloodType;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.redDark,
                    onPrimary: Colors.white,
                    surface: Color.fromARGB(255, 37, 37, 37),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.redDark,
                    onPrimary: Colors.white,
                    surface: AppColors.lightSurface,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
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
          icon: Icon(Icons.arrow_back_ios, color: cs.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    'STEP 2 OF 4',
                    style: TextStyle(
                      color: AppColors.redDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => _buildProgressStep(index <= 1, context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Personal Info',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Tell us a bit about yourself',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),

            _buildLabel('DATE OF BIRTH'),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: () => _selectDate(context),
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration(
                hint: '06/15/1995',
                icon: Icons.calendar_today_outlined,
                context: context,
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('GENDER'),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? const Color.fromARGB(255, 37, 37, 37) : AppColors.lightCard,

              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: cs.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
              decoration: _inputDecoration(hint: 'Select Gender', context: context),
            ),
            const SizedBox(height: 20),

            _buildLabel('WEIGHT (KG)'),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration(hint: 'e.g. 70', suffix: 'kg', context: context),
            ),
            const SizedBox(height: 30),

            _buildLabel('BLOOD TYPE'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
              ),
              itemCount: _bloodTypes.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedBloodType == _bloodTypes[index];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedBloodType = _bloodTypes[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.redDark
                          : (isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _bloodTypes[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightCard,
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(color: cs.onSurface),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_dobController.text.isEmpty ||
                          _selectedBloodType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete your info'),
                          ),
                        );
                        return;
                      }

                      Navigator.pushNamed(context, Routes.donorRegisterHealthRoute, arguments: {'fullName': widget.fullName, 'email': widget.email, 'phone': widget.phone, 'pass': widget.pass, 'dob': _dobController.text, 'gender': _selectedGender!, 'bloodType': _selectedBloodType!, 'weight': _weightController.text});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redDark,
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    String? suffix,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightCard,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: Colors.grey, size: 20)
          : null,
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark ? BorderSide.none : BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  Widget _buildProgressStep(bool isActive, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 4,
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.redDark
            : cs.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
