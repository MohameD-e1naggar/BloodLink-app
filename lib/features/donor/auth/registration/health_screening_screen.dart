import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:www/features/donor/auth/registration/review_summary_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';

class HealthScreeningScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String bloodType;
  final String weight;
  final String pass;

  const HealthScreeningScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.bloodType,
    required this.weight,
    required this.pass
  });

  @override
  State<HealthScreeningScreen> createState() => _HealthScreeningScreenState();
}

class _HealthScreeningScreenState extends State<HealthScreeningScreen> {
  bool _hasChronicDiseases = false;
  bool _takesRegularMedication = false;
  bool _hadRecentSurgery = false;
  bool _hasAnemia = false;

  final TextEditingController _lastDonationController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.redDark,
                    onPrimary: Colors.white,
                    surface: Color.fromARGB(255, 0, 0, 0),
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
        _lastDonationController.text =
            "${picked.month}/${picked.day}/${picked.year}";
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
                    'STEP 3 OF 4',
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
                      (index) => _buildProgressStep(index <= 2, context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Health Screening',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please provide accurate information for your safety and the recipient\'s.',
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 40),

            _buildHealthQuestion(
              title: 'Chronic diseases?',
              icon: Icons.add_moderator_outlined,
              value: _hasChronicDiseases,
              onChanged: (val) => setState(() => _hasChronicDiseases = val),
              context: context,
            ),
            const SizedBox(height: 12),
            _buildHealthQuestion(
              title: 'Regular medication?',
              icon: Icons.medication_outlined,
              value: _takesRegularMedication,
              onChanged: (val) => setState(() => _takesRegularMedication = val),
              context: context,
            ),
            const SizedBox(height: 12),
            _buildHealthQuestion(
              title: 'Recent surgery?',
              icon: Icons.medical_services_outlined,
              value: _hadRecentSurgery,
              onChanged: (val) => setState(() => _hadRecentSurgery = val),
              context: context,
            ),
            const SizedBox(height: 12),
            _buildHealthQuestion(
              title: 'Anemia?',
              icon: Icons.bloodtype_outlined,
              value: _hasAnemia,
              onChanged: (val) => setState(() => _hasAnemia = val),
              context: context,
            ),

            const SizedBox(height: 40),
            const Text(
              'Last Donation Date',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastDonationController,
              readOnly: true,
              onTap: () => _selectDate(context),
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightCard,
                hintText: 'mm/dd/yyyy',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                suffixIcon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: isDark ? BorderSide.none : BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'LEAVE BLANK IF THIS IS YOUR FIRST TIME',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.donorRegisterReviewRoute, arguments: {'fullName': widget.fullName, 'pass': widget.pass, 'email': widget.email, 'phone': widget.phone, 'dob': widget.dob, 'gender': widget.gender, 'bloodType': widget.bloodType, 'weight': widget.weight, 'hasChronicDiseases': _hasChronicDiseases, 'takesMedication': _takesRegularMedication, 'hadSurgery': _hadRecentSurgery, 'hasAnemia': _hasAnemia, 'lastDonation': _lastDonationController.text});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthQuestion({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1414) : AppColors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.redDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.redDark,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFF9E9E9E).withValues(alpha: 0.3),
        ),
      ],
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
