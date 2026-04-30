import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/hospital/notifications.dart';
import 'package:www/Backend/FirestoreHandler.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/Backend/models/User.dart' as my_user;

import 'request_screen.dart';
import 'search_screen.dart';

ValueNotifier<bool> refreshHospitalHome = ValueNotifier(false);
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String uid;
  late my_user.User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: refreshHospitalHome,
      builder: (context, value, child) {

        return FutureBuilder(
          future: FirestoreHandler.getUser(uid),
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
                body: Center(child: Text("Error: ${snapshot.error}")),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: Text("No user data")),
              );
            }
            user =  snapshot.data!;
            SharedPref.setUser(user);


            return Scaffold(
              backgroundColor: const Color(0xFF0F0F0F),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(), // الجزء الذي يحتوي على الجرس
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

  // --- الـ Top Bar مع أيقونة الجرس القابلة للضغط ---
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Color(0xFFE53935),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Hospital Unit #${user.id?.substring(3,7) ?? ""}',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                ),
              ],
            ),
          ],
        ),

        // زر الإشعارات المحدث (الجرس)
        GestureDetector(
          onTap: () {
            // كود الانتقال المباشر لشاشة الإشعارات
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          behavior: HitTestBehavior
              .opaque, // يضمن أن الضغطة يتم رصدها في كامل المنطقة
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // النقطة الحمراء
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 196, 0, 29),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F0F0F),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RequestBloodUnitsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFFE53935), size: 22),
            SizedBox(width: 10),
            Text(
              'Create Blood Request',
              style: TextStyle(
                color: Colors.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 196, 0, 29),
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
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1515),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.compare_arrows,
                          color: Color(0xFFE53935),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Requests',
                            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats['active']}',
                            style: const TextStyle(
                              color: Colors.white,
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
                        iconBg: const Color(0xFF2A2000),
                        label: 'Pending',
                        value: '${stats['pending']}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.verified_outlined,
                        iconColor: const Color(0xFF43A047),
                        iconBg: const Color(0xFF0A2A0A),
                        label: 'Fulfilled',
                        value: '${stats['fulfilled']}',
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

      final collection = FirestoreHandler.getReqCollection();
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
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
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BloodAvailabilityScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: const Center(
          child: Text(
            'Search For Blood Units',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIVE UPDATES',
          style: TextStyle(
            color: Color(0xFF888888),
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
              return const Text(
                'No request updates yet',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
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

      final collection = FirestoreHandler.getReqCollection();
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
        return const Color.fromARGB(255, 196, 0, 29);
      case 'fulfilled':
        return const Color(0xFF43A047);
      case 'rejected':
        return const Color.fromARGB(255, 196, 0, 29);
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
