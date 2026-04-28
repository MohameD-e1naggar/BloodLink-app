import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/FirestoreHandler.dart';
import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/donorScreens/makeAppointment.dart';
import 'package:www/data/blood_data.dart';
import 'package:www/data/requests_store.dart';
import 'Donation_Request_Details.dart';
import 'login_screen.dart';
import '../Backend/models/User.dart' as my_user;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {



  // الطلبات الطارئة من allRequests (اللي بعتها المستشفيات)


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث الشاشة لما نرجع إليها
    setState(() {});
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF250A0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // مسح كل البيانات عند الخروج
              allRequests.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Yes, Logout',
              style: TextStyle(
                color: Color(0xFFE53935),
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
      FirestoreHandler.getUser(uid) ,
      FirestoreHandler.getReqByDonorId(uid),
      FirestoreHandler.getCriticalReq(),
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
    // PopScope عشان زر الرجوع يفتح logout dialog بدل ما يخرج
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
          var requests = snapshot.data![1] as List<Request>;
          var user = snapshot.data![0] as my_user.User;
          var criticalRequests = snapshot.data![2] as List<Request>;


           SharedPref.setReqs(requests);
           SharedPref.setUser(user);

          Map<String, int> status = countPendingRequests(requests);

          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [Color(0xFF250A0A), Colors.black],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(user.name ?? "",requests.length),
                      const SizedBox(height: 10),
                      _buildStatsSection(status),
                      const SizedBox(height: 20),
                      _buildDonateToBanksButton(context),
                      const SizedBox(height: 25),
                      _buildSectionHeader('Urgent Requests'),
                      const SizedBox(height: 15),
                      _buildUrgentRequestsGrid(criticalRequests),
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

  Widget _buildAppBar(String name,int reqNum) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            name,
            style: TextStyle(
              color: Colors.white,
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
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
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
                      color: const Color(0xFFE53935),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== القسم الإحصائي الحقيقي =====
  Widget _buildStatsSection(Map<String,int> status) {

    return Column(
      children: [
        // كارت Active Requests الرئيسي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                  color: Color(0xFFE53935),
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // كارتين Pending و Fulfilled
        Row(
          children: [
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.access_time,
                iconColor: const Color(0xFFFFB300),
                iconBg: const Color(0xFF2A2000),
                label: 'Pending',
                value: status['pending'].toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.verified_outlined,
                iconColor: const Color(0xFF43A047),
                iconBg: const Color(0xFF0A2A0A),
                label: 'Fulfilled',
                value: status['fulfilled'].toString(),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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

  Widget _buildDonateToBanksButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BloodBanksScreen()),
          );
          // تحديث الإحصائيات بعد الرجوع
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

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => setState(() {}),
          child: const Text(
            'LIVE UPDATES',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentRequestsGrid(List<Request> urgentRequests) {
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
          _buildRequestCard(urgentRequests[index], index),
    );
  }

  Widget _buildRequestCard(Request request, int index) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                  color: null,
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
                    color: null,
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
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DonationDetailsScreen( request: request,),
                  ),
                );
                // تحديث الإحصائيات بعد الرجوع من تفاصيل الطلب
                if (mounted) setState(() {});
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.transparent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Donate Now',
                style: TextStyle(
                  color: null,
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
