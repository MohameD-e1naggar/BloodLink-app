import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:www/donorScreens/request_screen.dart';
import 'package:www/data/requests_store.dart';

class DonationDetailsScreen extends StatelessWidget {
  final int requestIndex;

  const DonationDetailsScreen({super.key, required this.requestIndex});

  Map<String, dynamic> get _request => allRequests[requestIndex];

  void _handleAcceptDonation(BuildContext context) {
    allRequests[requestIndex]['status'] = 'Accepted';
    allRequests[requestIndex]['statusColor'] = Colors.green;

    globalMyRequests.add({
      'hospital': _request['hospital'] ?? 'Unknown Hospital',
      'type': _request['bloodType'] ?? '?',
      'status': _request['isEmergency'] == true ? 'URGENT' : 'CONFIRMED',
      'date': DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
      'time': DateFormat('hh:mm a').format(DateTime.now()),
      'donors': '1',
    });

    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Donation Accepted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This request has been added to your My Requests list.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // إغلاق الدايلوج فقط، ثم pop للشاشة السابقة (الـ wrapper)
                  Navigator.pop(context); // إغلاق الدايلوج
                  Navigator.pop(context); // الرجوع للهوم (عبر الـ wrapper)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4001D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isEmergency = _request['isEmergency'] ?? false;
    final String bloodType = _request['bloodType'] ?? '?';
    final String hospital = _request['hospital'] ?? 'Unknown Hospital';
    final int units = _request['units'] ?? 1;
    final String status = _request['status'] ?? 'Pending';

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 0, 0, 0)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Donation Request",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          // الرجوع للشاشة السابقة فقط (مش خروج من التطبيق)
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildEmergencyCard(bloodType, isEmergency),
            const SizedBox(height: 20),
            _buildMapPreview(),
            const SizedBox(height: 20),
            _buildHospitalCard(hospital, isDarkMode),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildSmallInfoCard(
                  "QUANTITY",
                  "$units Unit${units > 1 ? 's' : ''}",
                  isDarkMode,
                ),
                const SizedBox(width: 15),
                _buildSmallInfoCard("STATUS", status, isDarkMode),
              ],
            ),
            const SizedBox(height: 20),
            _buildClinicalNotes(isDarkMode, isEmergency, bloodType),
            const SizedBox(height: 30),
            status == 'Pending'
                ? _buildActionButtons(context)
                : _buildAlreadyHandled(status),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(String bloodType, bool isEmergency) {
    final color = isEmergency ? const Color(0xFFC4001D) : Colors.amber;
    final label = isEmergency ? "EMERGENCY" : "STANDARD REQUEST";
    final subtitle = isEmergency
        ? "Response requested within 30 mins"
        : "Scheduled donation request";
    final String polarity = bloodType.endsWith('-') ? 'Negative' : 'Positive';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(118, 37, 37, 37),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            isEmergency ? Icons.error : Icons.info_outline,
            color: color,
            size: 35,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                bloodType,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                polarity.toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.location_on, color: Color(0xFFC4001D), size: 50),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    "2.4 km away",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(String hospital, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromARGB(118, 37, 37, 37)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hospital,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Main Surgical Wing",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              Icon(Icons.phone, color: Colors.grey, size: 18),
              SizedBox(width: 10),
              Text(
                "+1 (555) 092-8834",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoCard(String title, String value, bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromARGB(118, 37, 37, 37)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalNotes(
    bool isDarkMode,
    bool isEmergency,
    String bloodType,
  ) {
    final notes = isEmergency
        ? "Trauma patient currently in emergency surgery. Severe blood loss reported. $bloodType supply at facility is critically low. Immediate transfusion required."
        : "Scheduled surgical procedure requiring $bloodType blood. Please arrive at the donation center at the specified time.";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromARGB(118, 37, 37, 37)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment, color: Color(0xFFC4001D), size: 20),
              SizedBox(width: 10),
              Text(
                "CLINICAL NOTES",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            notes,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _handleAcceptDonation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4001D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Accept Donation",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: TextButton(
            onPressed: () {
              allRequests[requestIndex]['status'] = 'Rejected';
              allRequests[requestIndex]['statusColor'] = Colors.red;
              Navigator.pop(context); // رجوع للشاشة السابقة فقط
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(118, 37, 37, 37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text("Decline"),
          ),
        ),
      ],
    );
  }

  Widget _buildAlreadyHandled(String status) {
    final color = status == 'Accepted' ? Colors.green : Colors.red;
    final icon = status == 'Accepted' ? Icons.check_circle : Icons.cancel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            "Request $status",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
