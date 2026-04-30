import 'package:flutter/material.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationDetailsScreen extends StatefulWidget {
  final Request request;
  final bool isAccepted;

  const DonationDetailsScreen({
    super.key,
    required this.request,
    this.isAccepted = false,
  });

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  bool get isEmergency => widget.request.urgency == Urgency.critical.name;

  bool isAcceptedLocal = false;
  bool isRejectedLocal = false;
  bool isLoadingLocalStatus = true;

  @override
  void initState() {
    super.initState();
    _loadLocalStatus();
  }

  Future<void> _loadLocalStatus() async {
    if (widget.request.id != null) {
      var uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        var user = await UserService.getUser(uid);
        if (user != null && mounted) {
          final accepted = user.acceptedCriticalReqs ?? [];
          final rejected = user.rejectedCriticalReqs ?? [];
          setState(() {
            isAcceptedLocal = accepted.contains(widget.request.id) || widget.isAccepted;
            isRejectedLocal = rejected.contains(widget.request.id);
            isLoadingLocalStatus = false;
          });
          return;
        }
      }
    }

    if (mounted) {
      setState(() => isLoadingLocalStatus = false);
    }
  }

  Future<void> _updateStatus(
      BuildContext context,
      RequestStatus status,
      ) async {
    if (widget.request.id == null) return;

    await RequestService.updateStatus(widget.request.id!, status);

    if (mounted) Navigator.pop(context, true);
  }

  void _handleAccept(BuildContext context) async {
    if (widget.request.id == null || widget.request.hospitalName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing hospital information')),
      );
      return;
    }

    await RequestService.incrementDonorsCounter(
      widget.request.id!,
    );
    await RequestService.decrementUnits(widget.request.id!);
    var uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await UserService.addAcceptedReq(uid, widget.request.id!);
    }

    if (mounted) {
      setState(() => isAcceptedLocal = true);
    }

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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Go to ${widget.request.hospitalName}',
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
                Navigator.pop(context);
                Navigator.pop(context, true);
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
    final status = widget.request.reqStatus ?? "pending";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Donation Request"),
        backgroundColor: Colors.transparent,
      ),
      body: isLoadingLocalStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildEmergencyCard(),
                  const SizedBox(height: 20),
                  _buildHospitalCard(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _infoCard("BLOOD TYPE", widget.request.bloodType ?? "?"),
                      const SizedBox(width: 10),
                      _infoCard("UNITS", "${isEmergency ? (widget.request.units ?? 0) : 1}"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _infoCard(
                    "DATE & TIME",
                    "${widget.request.date ?? ''} • ${widget.request.time ?? ''}",
                    expanded: false,
                  ),

                  const SizedBox(height: 20),

                  _buildQRPass(),

                  const SizedBox(height: 30),

                  if (isEmergency && status == RequestStatus.pending.name)
                    if (isAcceptedLocal)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 40),
                            const SizedBox(height: 10),
                            const Text(
                              "Request Accepted",
                              style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Please go ahead to ${widget.request.hospitalName ?? 'the hospital'}",
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () async {
                                if (widget.request.id != null) {
                                  var uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    await UserService.addHiddenReq(uid, widget.request.id!);
                                  }
                                }
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                              ),
                              child: const Text("Remove from my feed", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      )
                    else if (isRejectedLocal)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.cancel, color: Colors.red, size: 40),
                            const SizedBox(height: 10),
                            const Text(
                              "You have rejected this request",
                              style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () async {
                                if (widget.request.id != null) {
                                  var uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    await UserService.addHiddenReq(uid, widget.request.id!);
                                  }
                                }
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                              ),
                              child: const Text("Remove from my feed", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                if (widget.request.id != null) {
                                  var uid = FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    await UserService.addRejectedReq(uid, widget.request.id!);
                                  }
                                  setState(() => isRejectedLocal = true);
                                }
                              },
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
            widget.request.bloodType ?? "?",
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
              widget.request.hospitalName ?? "Unknown Hospital",
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
          _row("Hospital", widget.request.hospitalName ?? ""),
          _row("Blood Type", widget.request.bloodType ?? ""),
          _row("Date", widget.request.date ?? ""),
          _row("Time", widget.request.time ?? ""),
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