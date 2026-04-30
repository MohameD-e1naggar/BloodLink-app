import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/user.dart' as my_user;

class ReviewSummaryScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String dob;
  final String gender;
  final String bloodType;
  final String weight;
  final bool hasChronicDiseases;
  final bool takesMedication;
  final bool hadSurgery;
  final bool hasAnemia;
  final String lastDonation;
  final String pass;

  const ReviewSummaryScreen({
    super.key,
    required this.fullName,
    required this.pass,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.bloodType,
    required this.weight,
    required this.hasChronicDiseases,
    required this.takesMedication,
    required this.hadSurgery,
    required this.hasAnemia,
    required this.lastDonation,
  });

  @override
  State<ReviewSummaryScreen> createState() => _ReviewSummaryScreenState();
}

class _ReviewSummaryScreenState extends State<ReviewSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Review Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  const Text(
                    'STEP 4 OF 4',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 196, 0, 29),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => _buildProgressStep(true),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Confirm Your Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Double check your info before finishing.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('BASIC ACCOUNT'),
            _buildDataCard([
              _buildDataRow('Full Name', widget.fullName),
              _buildDataRow('Email', widget.email),
              _buildDataRow('Phone', widget.phone),
            ]),

            const SizedBox(height: 25),

            _buildSectionTitle('PERSONAL DETAILS'),
            _buildDataCard([
              _buildDataRow('Date of Birth', widget.dob),
              _buildDataRow('Gender', widget.gender),
              _buildDataRow('Weight', '${widget.weight} kg'),
            ]),

            const SizedBox(height: 25),

            _buildSectionTitle('MEDICAL SUMMARY'),
            _buildDataCard([
              _buildDataRow('Blood Type', widget.bloodType, isHighlight: true),
              _buildDataRow('Last Donation', widget.lastDonation),
              _buildDataRow(
                'Chronic Diseases',
                widget.hasChronicDiseases ? 'Yes' : 'No',
              ),
              _buildDataRow(
                'Regular Medication',
                widget.takesMedication ? 'Yes' : 'No',
              ),
              _buildDataRow('Recent Surgery', widget.hadSurgery ? 'Yes' : 'No'),
              _buildDataRow('Anemia', widget.hasAnemia ? 'Yes' : 'No'),
            ]),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true);
                  bool success = await _createAccount();
                  if (mounted) {
                    setState(() => _isLoading = false);
                    if (success) {
                      _showSuccessDialog(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 0, 29),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm & Register',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<bool> _createAccount() async {
    final UserCredential credential;
    final uid;
    try {
       credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.pass.trim(),
      );
       uid = credential.user!.uid;

       await UserService.createUser(my_user.User(
         id: uid,
         email: widget.email,
         name: widget.fullName,
           phoneNumber: widget.phone,
           donorDob:  widget.dob,
       donorGender: widget.gender,
       bloodType: widget.bloodType,
       weight: widget.weight,
       hasChronicDiseases: widget.hasChronicDiseases,
       hadSurgery: widget.hadSurgery,
           hasAnemia: widget.hasAnemia,
       takesMedication: widget.takesMedication,
       donorLastDonation: widget.lastDonation,
           type: my_user.UserTypes.donor.name,
       ));
       return true;
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    }
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDataCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(118, 37, 37, 37),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isHighlight
                    ? const Color.fromARGB(255, 196, 0, 29)
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: const Color.fromARGB(255, 196, 0, 29),
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'All Set!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your registration is complete.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, Routes.donorLoginRoute, (route) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 0, 29),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
