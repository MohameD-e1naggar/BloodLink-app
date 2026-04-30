import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/FirestoreHandler.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/bloodbank%20screens/bloodbank_home.dart';
import 'package:www/data/requests_store.dart';

import 'hospital_home.dart'; // استيراد ملف التخزين الموحد

class RequestBloodUnitsScreen extends StatefulWidget {
  const RequestBloodUnitsScreen({super.key});

  @override
  State<RequestBloodUnitsScreen> createState() =>
      _RequestBloodUnitsScreenState();
}

class _RequestBloodUnitsScreenState extends State<RequestBloodUnitsScreen> {
  String? _selectedBloodType;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController(); // أضفت حقل ملاحظات إضافي
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
            // حقل اختيار فصيلة الدم
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

            // حقل الكمية
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

            // زر الطوارئ
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

            // زر الإرسال
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
                  var user = await SharedPref.getUser();
                  var name = user?.name ?? "";


                  await FirestoreHandler.createReq(Request(
                    reqSender: ReqSender.hospital.name,
                    reqStatus: RequestStatus.pending.name,
                    bloodType: _selectedBloodType,
                    urgency: _isStatHigh ? Urgency.critical.name : Urgency.normal.name,
                    date: DateTime.now().toIso8601String().split('T').first,
                    hospitalId: uid,
                    units: int.parse(_quantityController.text),
                    time: TimeOfDay.now().format(context),
                    hospitalName: name,

                  ));
                  refreshHospitalHome.value = !refreshHospitalHome.value;
                  Navigator.pop(context); // العودة للشاشة السابقة
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
