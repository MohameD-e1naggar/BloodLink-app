import 'package:flutter/material.dart';

class DonationDetailsScreen extends StatelessWidget {
  final String hospitalName;
  final String bloodType;
  final String date;
  final String time;

  const DonationDetailsScreen({
    super.key,
    required this.hospitalName,
    required this.bloodType,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Donation Pass'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_2, color: Colors.white, size: 180),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              _row('Hospital', hospitalName),
              _row('Blood Type', bloodType),
              _row('Date', date),
              _row('Time', time),
              const SizedBox(height: 20),
              const Text(
                'Show this at reception',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
