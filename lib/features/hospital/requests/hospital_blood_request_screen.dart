import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/blood_request.dart';

import 'package:www/features/hospital/home/hospital_home_screen.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Request Blood',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Blood Type', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white),
              value: _selectedBloodType,
              items: _bloodTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedBloodType = val),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Units', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'STAT / Emergency',
                style: TextStyle(color: Colors.white),
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
                  backgroundColor: const Color(0xFFC4001D),
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
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    color: Colors.white,
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
