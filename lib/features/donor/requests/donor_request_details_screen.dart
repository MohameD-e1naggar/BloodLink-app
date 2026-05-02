import 'package:flutter/material.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:www/core/utiles/ThemeManager.dart';

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

    if (context.mounted) Navigator.pop(context, true);
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text(
              'Donation Accepted!',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : AppColors.lightCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Go to ${widget.request.hospitalName}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 123 Blood Center Street, Medical District',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.6),
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
                backgroundColor: AppColors.redDark,
              ),
              child: Text("Done", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.request.reqStatus ?? "pending";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Donation Request", style: TextStyle(color: cs.onSurface)),
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
                          color: Colors.green.withValues(alpha: 0.1),
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
                              style: TextStyle(color: cs.onSurface, fontSize: 16),
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
                                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300],
                              ),
                              child: Text("Remove from my feed", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                            )
                          ],
                        ),
                      )
                    else if (isRejectedLocal)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.redDark.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.redDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.cancel, color: AppColors.redDark, size: 40),
                            const SizedBox(height: 10),
                            const Text(
                              "You have rejected this request",
                              style: TextStyle(color: AppColors.redDark, fontSize: 18, fontWeight: FontWeight.bold),
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
                                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300],
                              ),
                              child: Text("Remove from my feed", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
                                backgroundColor: AppColors.redDark,
                              ),
                              child: const Text("Accept", style: TextStyle(color: Colors.white)),
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
                         Text(
                          "Please head to the ${widget.request.bloodBankName}",
                          style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
                        ),
                      ],
                    )

                  else if (!isEmergency && status == RequestStatus.pending.name)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "This is a standard donation request. No action needed.",
                              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                            ),
                          ),
                        ],
                      ),
                    )

                  else
                    Text(
                      "Request $status",
                      style: TextStyle(color: cs.onSurface),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmergencyCard() {
    final color = isEmergency ? AppColors.redDark : Colors.blue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.lightCard,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.lightCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.bloodtype, color: cs.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.request.bloodBankName ?? "Unknown BloodBank",
              style: TextStyle(color: cs.onSurface),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, {bool expanded = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: cs.onSurface)),
        ],
      ),
    );

    return expanded ? Expanded(child: card) : card;
  }

  Widget _buildQRPass() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.bloodtype_outlined, size: 150, color: cs.onSurface),
          const SizedBox(height: 10),
          const Divider(),
          _row("Blood Bank", widget.request.bloodBankName ?? ""),
          _row("Blood Type", widget.request.bloodType ?? ""),
          _row("Date", widget.request.date ?? ""),
          _row("Time", widget.request.time ?? ""),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
          Text(value, style: TextStyle(color: cs.onSurface)),
        ],
      ),
    );
  }
}