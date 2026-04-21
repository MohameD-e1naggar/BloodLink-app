import 'package:flutter/material.dart';
import 'review_summary_screen.dart';

class HealthScreeningScreen extends StatefulWidget {
  // استقبال البيانات من الخطوات السابقة
  final String fullName;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String bloodType;
  final String weight;

  const HealthScreeningScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.bloodType,
    required this.weight,
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: const Color.fromARGB(255, 196, 0, 29),
              onPrimary: Colors.white,
              surface: Color.fromARGB(255, 0, 0, 0),
              onSurface: Colors.white,
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
                      color: const Color.fromARGB(255, 196, 0, 29),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => _buildProgressStep(index <= 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Health Screening',
              style: TextStyle(
                color: Colors.white,
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
            ),
            const SizedBox(height: 12),
            _buildHealthQuestion(
              title: 'Regular medication?',
              icon: Icons.medication_outlined,
              value: _takesRegularMedication,
              onChanged: (val) => setState(() => _takesRegularMedication = val),
            ),
            const SizedBox(height: 12),
            _buildHealthQuestion(
              title: 'Recent surgery?',
              icon: Icons.medical_services_outlined,
              value: _hadRecentSurgery,
              onChanged: (val) => setState(() => _hadRecentSurgery = val),
            ),
            const SizedBox(height: 12),
            _buildHealthQuestion(
              title: 'Anemia?',
              icon: Icons.bloodtype_outlined,
              value: _hasAnemia,
              onChanged: (val) => setState(() => _hasAnemia = val),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(118, 37, 37, 37),
                hintText: 'mm/dd/yyyy',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                suffixIcon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
                  // تمرير "كل" البيانات مجمعة لشاشة المراجعة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewSummaryScreen(
                        fullName: widget.fullName,
                        email: widget.email,
                        phone: widget.phone,
                        dob: widget.dob,
                        gender: widget.gender,
                        bloodType: widget.bloodType,
                        weight: widget.weight,
                        hasChronicDiseases: _hasChronicDiseases,
                        takesMedication: _takesRegularMedication,
                        hadSurgery: _hadRecentSurgery,
                        hasAnemia: _hasAnemia,
                        lastDonation: _lastDonationController.text.isEmpty
                            ? "Never"
                            : _lastDonationController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 0, 29),
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
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1414),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 196, 0, 29),
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color.fromARGB(255, 196, 0, 29),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Color(0xFF9E9E9E).withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildProgressStep(bool isActive) {
    return Container(
      height: 4,
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color.fromARGB(255, 196, 0, 29)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
