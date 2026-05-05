import 'package:flutter/material.dart';
import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/features/hospital/home/hospital_notifications_screen.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/user.dart' as my_user;

import 'package:www/features/hospital/requests/hospital_blood_request_screen.dart';
import 'package:www/features/hospital/home/hospital_search_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';

ValueNotifier<bool> refreshHospitalHome = ValueNotifier(false);
class HospitalHomeScreen extends StatefulWidget {
  const HospitalHomeScreen({super.key});

  @override
  State<HospitalHomeScreen> createState() => _HospitalHomeScreenState();
}

class _HospitalHomeScreenState extends State<HospitalHomeScreen> {
  late String uid;
  late my_user.User user;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: refreshHospitalHome,
      builder: (context, value, child) {

        return FutureBuilder(
          future: UserService.getUser(uid),
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
                body: Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(child: Text("No user data", style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
              );
            }
            user =  snapshot.data!;
            SharedPreferencesHelper.setUser(user);

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildCreateBloodRequestButton(),
                      const SizedBox(height: 28),
                      _buildOverviewSection(),
                      const SizedBox(height: 20),
                      _buildSearchButton(),
                      const SizedBox(height: 28),
                      _buildLiveUpdates(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildTopBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : AppColors.lightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: AppColors.redDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text(
                  user.name ?? "",
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Hospital Unit #${user.id?.substring(3,7) ?? ""}',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ],
        ),

        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.hospitalNotificationsRoute,
              arguments: uid,
            );
          },
          behavior: HitTestBehavior
              .opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: cs.onSurface,
                  size: 20,
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.redDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateBloodRequestButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.hospitalBloodRequestRoute,
          arguments: user.name ?? "",
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.redDark, size: 22),
            SizedBox(width: 10),
            Text(
              'Create Blood Request',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overview',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.redDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Today's Stats",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, int>>(
          future: _getRequestStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data ?? {'active': 0, 'pending': 0, 'fulfilled': 0};

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A1515) : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.compare_arrows,
                          color: AppColors.redDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Requests',
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats['active']}',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.access_time,
                        iconColor: const Color(0xFFFFB300),
                        iconBg: isDark ? const Color(0xFF2A2000) : const Color(0xFFFFF8E1),
                        label: 'Pending',
                        value: '${stats['pending']}',
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.verified_outlined,
                        iconColor: const Color(0xFF43A047),
                        iconBg: isDark ? const Color(0xFF0A2A0A) : const Color(0xFFE8F5E9),
                        label: 'Fulfilled',
                        value: '${stats['fulfilled']}',
                        context: context,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<Map<String, int>> _getRequestStats() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return {'active': 0, 'pending': 0, 'fulfilled': 0};

      final collection = RequestService.collection();
      final querySnapshot = await collection
          .where('hospitalId', isEqualTo: userId)
          .get();

      final requests = querySnapshot.docs.map((doc) => doc.data()).toList();

      int activeCount = requests
          .where((r) => r.reqStatus == RequestStatus.approved.name)
          .length;
      int pendingCount = requests
          .where((r) => r.reqStatus == RequestStatus.pending.name)
          .length;
      int fulfilledCount = requests
          .where((r) => r.reqStatus == RequestStatus.fulfilled.name)
          .length;

      return {'active': activeCount, 'pending': pendingCount, 'fulfilled': fulfilledCount};
    } catch (e) {
      return {'active': 0, 'pending': 0, 'fulfilled': 0};
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.hospitalSearchRoute,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            'Search For Blood Units',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveUpdates() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIVE UPDATES',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<Request>>(
          future: _getRecentRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return Text(
                'No request updates yet',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
              );
            }

            return Column(
              children: List.generate(
                requests.length > 3 ? 3 : requests.length,
                (index) {
                  final req = requests[index];
                  final color = _getStatusColor(req.reqStatus);
                  final statusText = _getStatusText(req.reqStatus);

                  return Column(
                    children: [
                      _buildUpdateItem(
                        title: '${req.bloodType} ${req.urgency == 'critical' ? 'Emergency ' : ''}Request $statusText',
                        subtitle: '${req.bloodBankName ?? 'Blood Bank'} • ${req.time ?? 'N/A'}',
                        color: color,
                        context: context,
                      ),
                      if (index < (requests.length > 3 ? 2 : requests.length - 1))
                        const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<List<Request>> _getRecentRequests() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      final collection = RequestService.collection();
      final querySnapshot = await collection
          .where('hospitalId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF43A047);
      case 'pending':
        return AppColors.redDark;
      case 'fulfilled':
        return const Color(0xFF43A047);
      case 'rejected':
        return AppColors.redDark;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Sent';
      case 'fulfilled':
        return 'Fulfilled';
      case 'rejected':
        return 'Rejected';
      default:
        return '';
    }
  }

  Widget _buildUpdateItem({
    required String title,
    required String subtitle,
    required Color color,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
