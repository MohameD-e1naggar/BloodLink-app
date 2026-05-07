import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/utiles/theme_manager.dart';
import '../home/hospital_home_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedFilter = 'all';

  Future<List<Request>> _loadRequests() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final collection = RequestService.collection();

    final querySnapshot = await collection
        .where('hospitalId', isEqualTo: userId)
        .get();

    var requests = querySnapshot.docs.map((doc) => doc.data()).toList();

    requests = requests.where((r) => r.reqStatus != RequestStatus.fulfilled.name).toList();

    if (_selectedFilter == 'pending') {
      return requests
          .where((r) => r.reqStatus == RequestStatus.pending.name)
          .toList();
    } else if (_selectedFilter == 'approved') {
      return requests
          .where((r) => r.reqStatus == RequestStatus.approved.name)
          .toList();
    }

    return requests;
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

  String _getStatusDisplay(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'fulfilled':
        return 'Fulfilled';
      default:
        return 'Unknown';
    }
  }

  Future<void> _deleteRequest(Request req) async {
    if (req.id == null) return;

    await RequestService.delete(req.id!);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    refreshHospitalHome.value = !refreshHospitalHome.value ;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Blood Requests",
          style: tt.titleLarge?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Accepted', 'approved'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Request>>(
              future: _loadRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: TextStyle(color: cs.onSurface),
                    ),
                  );
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bloodtype_outlined,
                          color: cs.onSurface.withValues(alpha: 0.3),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No requests yet",
                          style: tt.bodyMedium?.copyWith(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return _buildRequestCard(request);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.redDark,
      side: BorderSide(
        color: isSelected ? AppColors.redDark : Colors.grey,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.grey[700]),
      ),
    );
  }

  Widget _buildRequestCard(Request req) {
    final isEmergency = req.urgency == Urgency.critical.name;
    final status = req.reqStatus;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isDark ? BorderSide.none : BorderSide(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      elevation: isDark ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isEmergency
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  child: Text(
                    req.bloodType ?? '?',
                    style: TextStyle(
                      color: isEmergency ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${isEmergency ? "CRITICAL Request" : "Normal Request"}\n"
                            "${req.units == 0 ? "By Donors" : "Blood Bank ${req.bloodBankName ?? "...."}"}",
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${req.units} Units • ${req.time ?? 'N/A'}",
                        style: tt.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusDisplay(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: cs.onSurface.withValues(alpha: 0.1)),
            if (status == RequestStatus.pending.name)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Waiting for blood bank response...",
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _deleteRequest(req);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              )
            else if (status == RequestStatus.approved.name)
              Column(
                children: [
                  // Countdown badge for emergency requests
                  if (isEmergency) _buildCountdownBadge(req.approvedAt),
                  if (isEmergency) const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            req.units == 0
                              ? "Request Approved (Donors ready)"
                              : "Blood bank ${req.bloodBankName ?? ""} approved your request",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  req.units == 0 ?SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (req.id != null) {
                          await RequestService.updateStatus(req.id!, RequestStatus.fulfilled);
                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request marked as fulfilled')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                      child: const Text("Mark as Fulfilled", style: TextStyle(color: Colors.white)),
                    ),
                  ) : SizedBox()
                ],
              )
            else if (status == RequestStatus.rejected.name)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Blood bank rejected your request",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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

    // Green >4h, orange 2–4h, red <2h
    final Color badgeColor = fraction > 0.66
        ? const Color(0xFF43A047)
        : fraction > 0.33
            ? Colors.orange
            : AppColors.redDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
