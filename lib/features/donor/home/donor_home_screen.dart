import 'package:www/core/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/features/donor/requests/donor_appointment_screen.dart';
import 'package:www/features/donor/auth/donor_login_screen.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> with RouteAware {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF250A0A) : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(color: cs.onSurface)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {

              Navigator.pushNamedAndRemoveUntil(context, Routes.donorLoginRoute, (route) => false);
            },
            child: const Text(
              'Yes, Logout',
              style: TextStyle(
                color: AppColors.redDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<List<dynamic>> loadData() {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    return Future.wait([
      UserService.getUser(uid) ,
      RequestService.getByDonorId(uid),
      RequestService.getCritical(),
    ]);
  }

  Map<String,int> countPendingRequests(List<Request> requests) {
    int pending = 0;
    int approved = 0;
    int fulfilled = 0;

    for (var req in requests) {
      if (req.reqStatus == RequestStatus.pending.name) {
        pending++;
      }else if (req.reqStatus == RequestStatus.approved.name){

        approved++;
      }else if (req.reqStatus == RequestStatus.fulfilled.name){
        fulfilled++;
      }

    }

    return {
      'pending' : pending,
      "approved" : approved,
      'fulfilled' : fulfilled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _showLogoutDialog(context);
      },
      child: FutureBuilder(
        future: loadData(),
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
              body: Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: cs.onSurface))),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(child: Text("No user data", style: TextStyle(color: cs.onSurface))),
            );
          }
          var requests = snapshot.data![1] as List<Request>;
          var user = snapshot.data![0] as my_user.User;
          var allCriticalRequests = snapshot.data![2] as List<Request>;
          var hiddenReqs = user.hiddenCriticalReqs ?? [];

          var filteredRequests = requests
              .where((req) => req.reqStatus != RequestStatus.fulfilled.name)
              .toList();
          var criticalRequests = allCriticalRequests
              .where((req) => req.reqStatus != RequestStatus.fulfilled.name && req.bloodType == user.bloodType && req.reqStatus != RequestStatus.approved.name &&!hiddenReqs.contains(req.id))
              .toList();

           SharedPreferencesHelper.setReqs(requests);
           SharedPreferencesHelper.setUser(user);

          Map<String, int> status = countPendingRequests(requests);

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const RadialGradient(
                        center: Alignment(0, -0.5),
                        radius: 1.2,
                        colors: [Color(0xFF250A0A), Colors.black],
                      )
                    : RadialGradient(
                        center: Alignment(0, -0.5),
                        radius: 1.2,
                        colors: [AppColors.lightCard, AppColors.lightSurface],
                      ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(user.name ?? "",filteredRequests.length, context),
                      const SizedBox(height: 10),
                      _buildStatsSection(status, context),
                      const SizedBox(height: 20),
                      _buildDonateToBanksButton(context),
                      const SizedBox(height: 25),
                      _buildSectionHeader('Urgent Requests', context),
                      const SizedBox(height: 15),
                      _buildUrgentRequestsGrid(criticalRequests, context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildAppBar(String name, int reqNum, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            name,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: cs.onSurface,
                  size: 24,
                ),
              ),
              if (reqNum > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: AppColors.redDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String,int> status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.onSurface.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text(
                'Active Requests',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                status['approved'].toString(),
                style: const TextStyle(
                  color: AppColors.redDark,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.access_time,
                iconColor: const Color(0xFFFFB300),
                iconBg: isDark ? const Color(0xFF2A2000) : const Color(0xFFFFF8E1),
                label: 'Pending',
                value: status['pending'].toString(),
                context: context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.verified_outlined,
                iconColor: const Color(0xFF43A047),
                iconBg: isDark ? const Color(0xFF0A2A0A) : const Color(0xFFE8F5E9),
                label: 'Fulfilled',
                value: status['fulfilled'].toString(),
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
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
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
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

  Widget _buildDonateToBanksButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [AppColors.redDark, Color(0xFFB71C1C)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.redDark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.donorBloodBanksRoute);
          if (mounted) setState(() {});
        },
        icon: const Icon(
          Icons.local_hospital_rounded,
          color: Colors.white,
          size: 22,
        ),
        label: const Text(
          'DONATE TO BLOOD BANKS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => setState(() {}),
          child: const Text(
            'LIVE UPDATES',
            style: TextStyle(
              color: AppColors.redDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentRequestsGrid(List<Request> urgentRequests, BuildContext context) {
    if (urgentRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.bloodtype_outlined,
                color: Colors.grey.withOpacity(0.4),
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'No urgent requests at the moment',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: urgentRequests.length,
      itemBuilder: (context, index) =>
          _buildRequestCard(urgentRequests[index], index, context),
    );
  }

  Widget _buildRequestCard(Request request, int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: cs.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.bloodType ?? "",
                style: TextStyle(
                  color: AppColors.redDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  request.urgency ?? "",
                  style: TextStyle(
                    color: AppColors.redDark,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${request.units}\n${request.hospitalName}',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, Routes.donorRequestDetailsRoute, arguments: request);
                if (mounted) setState(() {});
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.transparent),
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.lightSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Donate Now',
                style: TextStyle(
                  color: AppColors.redDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
