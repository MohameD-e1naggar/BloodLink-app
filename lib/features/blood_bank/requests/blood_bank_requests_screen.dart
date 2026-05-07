import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/utiles/theme_manager.dart';

import 'package:www/core/models/blood_inventory.dart';
import 'package:www/features/blood_bank/home/blood_bank_home_screen.dart';
import 'package:www/core/services/emergency_reset_service.dart';

class BloodBankRequestsScreen extends StatefulWidget {
  const BloodBankRequestsScreen({super.key});

  @override
  State<BloodBankRequestsScreen> createState() =>
      _BloodBankRequestsScreenState();
}

class _BloodBankRequestsScreenState extends State<BloodBankRequestsScreen> {
  Future<List<Request>> loadRequests() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return RequestService.getIncomingForBloodBank(uid);
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return AppColors.redDark;
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

    await RequestService.updateStatus(req.id!, status);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<Request>>(
      future: loadRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: cs.onSurface),
              ),
            ),
          );
        }

        final filteredRequests = snapshot.data ?? [];


        final requests = filteredRequests
            .where((request) => request.units != 0)
            .toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Blood Bank Requests",
              style: TextStyle(color: cs.onSurface),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: requests.isEmpty
              ? Center(
            child: Text(
              "No requests",
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final status = req.reqStatus;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
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
                  backgroundColor: isEmergency
                      ? AppColors.redDark.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  child: Text(
                    req.bloodType ?? '?',
                    style: TextStyle(
                      color: isEmergency ? AppColors.redDark : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (req.reqSender == ReqSender.hospital.name)
                        Text(
                          req.hospitalName ?? "",
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        FutureBuilder<String>(
                          future: req.donorId != null
                              ? UserService.getUser(req.donorId!)
                                  .then((u) => u?.name ?? 'Unknown Donor')
                              : Future.value('Unknown Donor'),
                          builder: (context, snap) {
                            final name = snap.data ?? 'Loading...';
                            return Text(
                              name,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      Text(
                        "${req.reqSender == ReqSender.hospital.name ? "${req.units} Units •" : ""}  ${req.time ?? ''} ${req.reqSender == ReqSender.hospital.name ? "" : " • ${req.date}"}",
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Countdown badge for approved emergency requests ──────────
            if (isEmergency && status == RequestStatus.approved.name)
              _buildCountdownBadge(req.approvedAt),

            Divider(color: isDark ? const Color(0xFF333333) : cs.onSurface.withValues(alpha: 0.1)),

            if (status == RequestStatus.pending.name)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(req, RequestStatus.rejected),
                      child: Text(
                        "Reject",
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        var user = await SharedPreferencesHelper.getUser();
                        await RequestService.updateBloodBank(
                            req.id ?? "",
                            user?.name ?? "",
                            user?.id ?? ""
                        );
                          _updateStatus(req, RequestStatus.approved);
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redDark,
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )

            else if (status == RequestStatus.approved.name)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
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
                          final inventory = await InventoryService.get(uid);
                          if (inventory == null) return;

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

                          await InventoryService.updateInventory(uid, Inventory(
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
                        backgroundColor: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      child: const Text("Fulfill", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )

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

  Widget _buildCountdownBadge(String? approvedAt) {
    final remaining = EmergencyResetService.remainingTime(approvedAt);
    if (remaining == null) return const SizedBox.shrink();

    final label = EmergencyResetService.formatCountdown(remaining);
    final totalSeconds = remaining.inSeconds;
    final maxSeconds = const Duration(hours: 6).inSeconds;
    final fraction = totalSeconds / maxSeconds;

    // Green when >4h, orange between 2–4h, red when <2h
    final Color badgeColor = fraction > 0.66
        ? const Color(0xFF43A047)
        : fraction > 0.33
            ? Colors.orange
            : AppColors.redDark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: badgeColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}