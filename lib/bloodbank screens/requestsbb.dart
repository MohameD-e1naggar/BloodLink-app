import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/Backend/FirestoreHandler.dart';

import '../Backend/models/Inventory.dart';
import 'bloodbank_home.dart';

class BloodBankRequestsScreen extends StatefulWidget {
  const BloodBankRequestsScreen({super.key});

  @override
  State<BloodBankRequestsScreen> createState() =>
      _BloodBankRequestsScreenState();
}

class _BloodBankRequestsScreenState extends State<BloodBankRequestsScreen> {
  Future<List<Request>> loadRequests() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirestoreHandler.getIncomingRequests(uid);
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      case 'fulfilled':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  Future<void> _updateStatus(
      Request req,
      RequestStatus status,
      ) async {
    if (req.id == null) return;

    await FirestoreHandler.updateStatus(req.id!, status);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Request>>(
      future: loadRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final requests = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F0F),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "Blood Bank Requests",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF0F0F0F),
            elevation: 0,
          ),
          body: requests.isEmpty
              ? const Center(
            child: Text(
              "No requests",
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return _buildCard(req);
            },
          ),
        );
      },
    );
  }
  Widget _buildCard(Request req) {
    final isEmergency = req.urgency == Urgency.critical.name;

    final status = req.reqStatus;

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
            // ===== HEADER (same as yours) =====
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isEmergency
                      ? Colors.red.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  child: Text(
                    req.bloodType ?? '?',
                    style: TextStyle(
                      color: isEmergency ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.reqSender == ReqSender.hospital.name
                            ? req.hospitalName ?? ""
                            : "Donor",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${req.reqSender == ReqSender.hospital.name ? "${req.units} Units •" : ""}  ${req.time ?? ''}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(color: Color(0xFF333333)),

            // ===================== STATE MACHINE UI =====================

            // 1️⃣ PENDING → ACCEPT / REJECT
            if (status == RequestStatus.pending.name)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(req, RequestStatus.rejected),
                      child: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        var user = await SharedPref.getUser();
                        await FirestoreHandler.updateReqBloodBank(
                            req.id ?? "",
                            user?.name ?? "",
                            user?.id ?? ""
                        );
                          _updateStatus(req, RequestStatus.approved);
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC4001D),
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )

            // 2️⃣ APPROVED → FULFILL
            else if (status == RequestStatus.approved.name)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Request Accepted",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{

                          _updateStatus(req, RequestStatus.fulfilled);
                         var uid = FirebaseAuth.instance.currentUser!.uid;
                          final ref = FirestoreHandler.getInventoryDoc(uid);
                          final doc = await ref.get();
                          final inventory = doc.data()!;

                          Map<String, int> updated = inventory.toBloodMap();

                          if (req.reqSender == ReqSender.donor.name) {
                            updated[req.bloodType!] =
                                ((updated[req.bloodType!] ?? 0) + 1);
                          } else {
                            final current = updated[req.bloodType!] ?? 0;
                            final units = req.units ?? 0;
                            updated[req.bloodType!] =
                                (current - units).clamp(0, 9999).toInt();
                          }

                          await ref.set(Inventory(
                            aPos: updated['A+'],
                            aNeg: updated['A-'],
                            bPos: updated['B+'],
                            bNeg: updated['B-'],
                            oPos: updated['O+'],
                            oNeg: updated['O-'],
                            abPos: updated['AB+'],
                            abNeg: updated['AB-'],
                          ));
                          refreshHome.value = !refreshHome.value;
                          setState(() {

                          });

                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Fulfill"),
                    ),
                  ),
                ],
              )

            // 3️⃣ FINAL STATES
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Request ${req.reqStatus}",
                  style: TextStyle(
                    color: _getStatusColor(req.reqStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


}