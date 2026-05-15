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
  Future<List<Request>> _loadIncoming() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return RequestService.getIncomingForBloodBank(uid);
  }

  Future<List<Request>> _loadSent() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return RequestService.getOutgoingForBloodBank(uid);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Blood Bank Requests",
            style: TextStyle(color: cs.onSurface),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: cs.onSurface),
              onPressed: () => setState(() {}),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.redDark,
            labelColor: AppColors.redDark,
            unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
            tabs: const [
              Tab(text: "INCOMING"),
              Tab(text: "SENT"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(_loadIncoming, isIncoming: true),
            _buildRequestsList(_loadSent, isIncoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(Future<List<Request>> Function() loader, {required bool isIncoming}) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<Request>>(
      future: loader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: cs.onSurface)));
        }

        final requests = (snapshot.data ?? [])
            .where((r) => isIncoming ? r.units != 0 : true)
            .toList();

        if (requests.isEmpty) {
          return Center(
            child: Text(
              isIncoming ? "No incoming requests" : "No sent requests",
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return _buildCard(req, isIncoming: isIncoming);
          },
        );
      },
    );
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

  Future<void> _updateStatus(Request req, RequestStatus status) async {
    if (req.id == null) return;
    await RequestService.updateStatus(req.id!, status);
    if (mounted) setState(() {});
  }

  Widget _buildCard(Request req, {required bool isIncoming}) {
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
                      Text(
                        isIncoming 
                          ? (req.reqSender == ReqSender.hospital.name 
                              ? (req.hospitalName ?? "Hospital") 
                              : (req.reqSender == ReqSender.bloodBank.name 
                                  ? (req.requesterName ?? "Blood Bank") 
                                  : "Donor Request"))
                          : (req.requesterName ?? "My Request"),
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${req.units} Units • ${req.time ?? ''}",
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status?.toUpperCase() ?? 'PENDING',
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (isEmergency && status == RequestStatus.approved.name)
              _buildCountdownBadge(req.approvedAt),
            Divider(color: isDark ? const Color(0xFF333333) : cs.onSurface.withValues(alpha: 0.1)),
            
            if (isIncoming)
              // Incoming request actions (Accept/Reject/Fulfill)
              if (status == RequestStatus.pending.name)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(req, RequestStatus.rejected),
                        child: Text("Reject", style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final uid = FirebaseAuth.instance.currentUser!.uid;
                          final inventory = await InventoryService.get(uid);
                          
                          if (inventory != null) {
                            final currentStock = inventory.toBloodMap()[req.bloodType!] ?? 0;
                            final neededUnits = req.units ?? 0;
                            
                            if (currentStock < (neededUnits + 10)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Insufficient stock. You need at least ${neededUnits + 10} units of ${req.bloodType} to accept this (including 10 safety units).'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }
                          }

                          var user = await SharedPreferencesHelper.getUser();
                          await RequestService.updateBloodBank(req.id ?? "", user?.name ?? "", user?.id ?? "");
                          _updateStatus(req, RequestStatus.approved);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.redDark),
                        child: const Text("Accept", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              else if (status == RequestStatus.approved.name)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _updateStatus(req, RequestStatus.fulfilled);
                      var uid = FirebaseAuth.instance.currentUser!.uid;
                      final inventory = await InventoryService.get(uid);
                      if (inventory == null) return;

                      Map<String, int> updated = inventory.toBloodMap();
                      if (req.reqSender == ReqSender.donor.name) {
                        updated[req.bloodType!] = (updated[req.bloodType!] ?? 0) + 1;
                      } else {
                        updated[req.bloodType!] = ((updated[req.bloodType!] ?? 0) - (req.units ?? 0)).clamp(0, 9999);
                      }

                      await InventoryService.updateInventory(uid, Inventory.fromMap(updated));
                      refreshHome.value = !refreshHome.value;
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Fulfill & Deduct Stock", style: TextStyle(color: Colors.white)),
                  ),
                )
              else
                Text("Request $status", style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold))
            
            else
              // Sent request actions (Sender CANNOT fulfill, only view)
              if (status == RequestStatus.approved.name)
                Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      "Wait for ${req.bloodBankName ?? 'the blood bank'} to fulfill",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              else if (status == RequestStatus.pending.name)
                Text("Waiting for other blood banks...", style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontStyle: FontStyle.italic))
              else
                Text("Status: ${status?.toUpperCase()}", style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
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
    final fraction = totalSeconds / const Duration(hours: 6).inSeconds;
    final Color badgeColor = fraction > 0.66 ? const Color(0xFF43A047) : fraction > 0.33 ? Colors.orange : AppColors.redDark;

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
          Text(label, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
