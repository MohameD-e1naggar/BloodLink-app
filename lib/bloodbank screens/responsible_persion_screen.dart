import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:www/bloodbank%20screens/location_screen.dart';

// تأكد من استيراد ملف الشاشة الثالثة هنا

class ResponsiblePersonScreenbb extends StatefulWidget {

  final String bankName;
  final String email;
  final String pass;
  final String phoneNumber;
  final String address;
  final String workingHours;
  const ResponsiblePersonScreenbb(
      {
        super.key,
        required this.phoneNumber,
        required this.bankName,
        required this.email,
        required this.pass,
        required this.address,
        required this.workingHours,

      });

  @override
  State<ResponsiblePersonScreenbb> createState() =>
      _ResponsiblePersonScreenbbState();
}

class _ResponsiblePersonScreenbbState extends State<ResponsiblePersonScreenbb> {
  final _formKey = GlobalKey<FormState>();

  final _adminNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  String _adminPhoneNumber = '';

  @override
  void dispose() {
    _adminNameController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120808),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 196, 0, 29),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'MedRegistry',
              style: TextStyle(
                color: Colors.white,
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
                // PROGRESS HEADER
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REGISTRATION PROGRESS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Step 2 of 3',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 196, 0, 29),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.66,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color.fromARGB(255, 196, 0, 29),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Responsible Person',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Details of the bloodbank administrator',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),

                _buildFieldLabel('Responsible Person Name'),
                _buildTextField(
                  controller: _adminNameController,
                  hint: 'Enter full name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('National ID of Responsible Person'),
                _buildTextField(
                  controller: _nationalIdController,
                  hint: 'ID Number (e.g. 123456789)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.length < 10) {
                      return 'Enter a valid ID number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('Phone Number of Responsible Person'),
                IntlPhoneField(
                  initialCountryCode: 'EG',
                  dropdownTextStyle: const TextStyle(color: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: const Color.fromARGB(255, 196, 0, 29),
                  languageCode: "en",
                  onChanged: (phone) =>
                      _adminPhoneNumber = phone.completeNumber,
                  decoration: _inputDecoration(hint: '(555) 000-0000'),
                ),
                const SizedBox(height: 40),

                // زر NEXT المحدث للانتقال
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_adminPhoneNumber.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter phone number'),
                            ),
                          );
                          return;
                        }

                        // الانتقال للشاشة الثالثة
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                 bloodbankLocationScreen(
                                  email: widget.email ,
                                   pass: widget.pass,
                                   phoneNumber: widget.phoneNumber,
                                   bankName: widget.bankName,
                                   adminName: _adminNameController.text.trim(),
                                   adminNationalId: _nationalIdController.text.trim(),
                                   adminPhoneNumber: _adminPhoneNumber.trim(),
                                   workingHours: widget.workingHours,
                                   address: widget.address,

                                ),
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
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // زر BACK
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white70,
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF1E1414),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
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
}
