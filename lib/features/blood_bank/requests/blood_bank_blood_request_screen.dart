import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/services/request_service.dart';
import 'package:www/features/blood_bank/home/blood_bank_home_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class BloodBankBloodRequestScreen extends StatefulWidget {
  final String bankName;
  const BloodBankBloodRequestScreen({super.key, required this.bankName});

  @override
  State<BloodBankBloodRequestScreen> createState() =>
      _BloodBankBloodRequestScreenState();
}

class _BloodBankBloodRequestScreenState extends State<BloodBankBloodRequestScreen> {
  String? _selectedBloodType;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

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

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
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
        title: Text(
          'Emergency Blood Request',
          style: TextStyle(color: cs.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All blood bank requests are marked as CRITICAL by default to ensure immediate visibility to donors and other banks.',
                      style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Blood Type', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
              style: TextStyle(color: cs.onSurface),
              value: _selectedBloodType,
              items: _bloodTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedBloodType = val),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: cs.onSurface.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.redDark),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Units Required', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter number of units',
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.3)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: cs.onSurface.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.redDark),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () async{
                  if (_selectedBloodType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select blood type')),
                    );
                    return;
                  }
                  if (_quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter units quantity')),
                    );
                    return;
                  }
                  
                  var uid = FirebaseAuth.instance.currentUser?.uid;

                  await RequestService.create(Request(
                    reqSender: ReqSender.bloodBank.name,
                    reqStatus: RequestStatus.pending.name,
                    bloodType: _selectedBloodType,
                    urgency: Urgency.critical.name,
                    date: DateTime.now().toIso8601String().split('T').first,
                    requesterId: uid, // Sender ID for BB
                    requesterName: widget.bankName, // Preserve original name
                    units: int.parse(_quantityController.text),
                    time: TimeOfDay.now().format(context),
                    bloodBankName: null, // No fulfiller yet
                    donorsAcceptedCriticalReqNum: 0
                  ));
                  
                  refreshHome.value = !refreshHome.value;
                  Navigator.pop(context);
                },
                child: const Text(
                  'SUBMIT CRITICAL REQUEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
