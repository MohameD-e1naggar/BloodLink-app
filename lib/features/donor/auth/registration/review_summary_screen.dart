import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Review Summary',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  const Text(
                    'STEP 4 OF 4',
                    style: TextStyle(
                      color: AppColors.redDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => _buildProgressStep(true, context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Confirm Your Details',
              style: TextStyle(
                color: cs.onSurface,
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
              _buildDataRow('Full Name', widget.fullName, context),
              _buildDataRow('Email', widget.email, context),
              _buildDataRow('Phone', widget.phone, context),
            ], context),

            const SizedBox(height: 25),

            _buildSectionTitle('PERSONAL DETAILS'),
            _buildDataCard([
              _buildDataRow('Date of Birth', widget.dob, context),
              _buildDataRow('Gender', widget.gender, context),
              _buildDataRow('Weight', '${widget.weight} kg', context),
            ], context),

            const SizedBox(height: 25),

            _buildSectionTitle('MEDICAL SUMMARY'),
            _buildDataCard([
              _buildDataRow('Blood Type', widget.bloodType, context, isHighlight: true),
              _buildDataRow('Last Donation', widget.lastDonation, context),
              _buildDataRow(
                'Chronic Diseases',
                widget.hasChronicDiseases ? 'Yes' : 'No',
                context,
              ),
              _buildDataRow(
                'Regular Medication',
                widget.takesMedication ? 'Yes' : 'No',
                context,
              ),
              _buildDataRow('Recent Surgery', widget.hadSurgery ? 'Yes' : 'No', context),
              _buildDataRow('Anemia', widget.hasAnemia ? 'Yes' : 'No', context),
            ], context),

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
                  backgroundColor: AppColors.redDark,
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

  Widget _buildDataCard(List<Widget> children, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(118, 37, 37, 37) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDataRow(String label, String value, BuildContext context, {bool isHighlight = false}) {
    final cs = Theme.of(context).colorScheme;
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
                    ? AppColors.redDark
                    : cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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

  void _showSuccessDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color.fromARGB(255, 0, 0, 0) : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.redDark,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'All Set!',
              style: TextStyle(
                color: cs.onSurface,
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
                  backgroundColor: AppColors.redDark,
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
