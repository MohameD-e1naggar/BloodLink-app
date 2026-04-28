import 'package:flutter/material.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/Backend/FirestoreHandler.dart';

class DonationDetailsScreen extends StatelessWidget {
  final Request request;

  const DonationDetailsScreen({
    super.key,
    required this.request,
  });

  bool get isEmergency => request.urgency == Urgency.critical.name;

  Future<void> _updateStatus(
      BuildContext context,
      RequestStatus status,
      ) async {
    if (request.id == null) return;

    await FirestoreHandler.updateStatus(request.id!, status);

    // 🔥 return to previous screen and trigger refresh
    Navigator.pop(context, true);
  }

  // ✅ FIXED: dialog handles update + navigation
  void _handleAccept(BuildContext context) async {
    // Safety check for required data
    if (request.id == null || request.hospitalName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing hospital information')),
      );
      return;
    }

    await FirestoreHandler.updateStatus(
      request.id!,
      RequestStatus.approved,
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Donation Accepted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            // Hospital address info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Go to ${request.hospitalName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '📍 123 Blood Center Street, Medical District',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, true); // go back + refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4001D),
              ),
              child: const Text("Done"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = request.reqStatus ?? "pending";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Donation Request"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEmergencyCard(),
            const SizedBox(height: 20),
            _buildHospitalCard(),
            const SizedBox(height: 20),

            // 📊 INFO
            Row(
              children: [
                _infoCard("BLOOD TYPE", request.bloodType ?? "?"),
                const SizedBox(width: 10),
                _infoCard("UNITS", "${isEmergency ? (request.units ?? 0) : 1}"),
              ],
            ),

            const SizedBox(height: 20),

            _infoCard(
              "DATE & TIME",
              "${request.date ?? ''} • ${request.time ?? ''}",
              expanded: false,
            ),

            const SizedBox(height: 20),

            _buildQRPass(),

            const SizedBox(height: 30),

            // 🔘 ACTIONS FLOW - Only show for critical requests
            if (isEmergency && status == RequestStatus.pending.name)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(
                        context,
                        RequestStatus.rejected,
                      ),
                      child: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAccept(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC4001D),
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                ],
              )

            else if (status == RequestStatus.approved.name)
              Column(
                children: [
                  const Text(
                    "Request Approved",
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _updateStatus(
                      context,
                      RequestStatus.fulfilled,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Mark as Fulfilled"),
                  )
                ],
              )

            else if (!isEmergency && status == RequestStatus.pending.name)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "This is a standard donation request. No action needed.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )

            else
              Text(
                "Request $status",
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _buildEmergencyCard() {
    final color = isEmergency ? Colors.red : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEmergency ? "CRITICAL REQUEST" : "STANDARD REQUEST",
              style: TextStyle(color: color),
            ),
          ),
          Text(
            request.bloodType ?? "?",
            style: TextStyle(color: color, fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _buildHospitalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              request.hospitalName ?? "Unknown Hospital",
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, {bool expanded = true}) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
    
    return expanded ? Expanded(child: card) : card;
  }

  Widget _buildQRPass() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2, size: 150, color: Colors.white),
          const SizedBox(height: 10),
          const Divider(),
          _row("Hospital", request.hospitalName ?? ""),
          _row("Blood Type", request.bloodType ?? ""),
          _row("Date", request.date ?? ""),
          _row("Time", request.time ?? ""),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}