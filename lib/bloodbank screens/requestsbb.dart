import 'package:flutter/material.dart';
import 'package:www/data/requests_store.dart'; // استيراد المتجر الموحد

class BloodBankRequestsScreen extends StatefulWidget {
  const BloodBankRequestsScreen({super.key});

  @override
  State<BloodBankRequestsScreen> createState() =>
      _BloodBankRequestsScreenState();
}

class _BloodBankRequestsScreenState extends State<BloodBankRequestsScreen> {
  // دالة لتحديث الحالة واللون ليظهر التغيير في كل مكان
  void _updateStatus(int index, String newStatus) {
    setState(() {
      allRequests[index]['status'] = newStatus;

      // تحديث اللون بناءً على الحالة الجديدة
      if (newStatus == 'Accepted') {
        allRequests[index]['statusColor'] = Colors.green;
      } else if (newStatus == 'Rejected') {
        allRequests[index]['statusColor'] = Colors.red;
      } else {
        allRequests[index]['statusColor'] = Colors.blue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "Hospital Requests",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: allRequests.isEmpty
          ? const Center(
              child: Text(
                "No incoming hospital requests",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allRequests.length,
              itemBuilder: (context, index) {
                final req = allRequests[index];
                return Card(
                  color: const Color(0xFF1A1A1A),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (req['isEmergency'] ?? false)
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              child: Text(
                                req['bloodType'] ?? '?',
                                style: TextStyle(
                                  color: (req['isEmergency'] ?? false)
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req['hospital'] ?? 'Hospital',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${req['units']} Units requested • ${req['time']}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (req['isEmergency'] ?? false)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  "STAT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(color: Color(0xFF333333)),

                        // زر قبول/رفض
                        req['status'] == 'Pending'
                            ? Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _updateStatus(index, 'Rejected'),
                                      child: const Text(
                                        "Reject",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _updateStatus(index, 'Accepted'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFC4001D,
                                        ),
                                      ),
                                      child: const Text(
                                        "Accept",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Request ${req['status']}",
                                    style: TextStyle(
                                      color: req['statusColor'] ?? Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
