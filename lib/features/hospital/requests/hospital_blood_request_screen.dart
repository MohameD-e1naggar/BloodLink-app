
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/blood_request.dart';

import 'package:www/features/hospital/home/hospital_home_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class HospitalBloodRequestScreen extends StatefulWidget {
  final String hospitalName;
  const HospitalBloodRequestScreen({super.key, required this.hospitalName});

  @override
  State<HospitalBloodRequestScreen> createState() =>
      _HospitalBloodRequestScreenState();
}

class _HospitalBloodRequestScreenState extends State<HospitalBloodRequestScreen> {
  String? _selectedBloodType;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isStatHigh = false;

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
          'Request Blood',
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
            Text('Blood Type', style: TextStyle(color: cs.onSurface)),
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
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Text('Units', style: TextStyle(color: cs.onSurface)),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'STAT / Emergency',
                style: TextStyle(color: cs.onSurface),
              ),
              value: _isStatHigh,
              onChanged: (val) => setState(() => _isStatHigh = val),
              activeColor: Colors.red,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redDark,
                ),
                onPressed: () async{
                  if (_selectedBloodType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select blood type')),
                    );
                    return;
                  }
                  var uid = FirebaseAuth.instance.currentUser?.uid;

                  await RequestService.create(Request(
                    reqSender: ReqSender.hospital.name,
                    reqStatus: RequestStatus.pending.name,
                    bloodType: _selectedBloodType,
                    urgency: _isStatHigh ? Urgency.critical.name : Urgency.normal.name,
                    date: DateTime.now().toIso8601String().split('T').first,
                    hospitalId: uid,
                    units: int.parse(_quantityController.text),
                    time: TimeOfDay.now().format(context),
                    hospitalName: widget.hospitalName,
                    donorsAcceptedCriticalReqNum: 0
                  ));
                  refreshHospitalHome.value = !refreshHospitalHome.value;
                  Navigator.pop(context);
                },
                child: Text(
                  'Submit Request',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
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
