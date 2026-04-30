import 'package:flutter/material.dart';

import 'package:www/Backend/cash/shared_pref.dart';
import 'package:www/Backend/models/Request.dart';
import '../Backend/models/User.dart' as my_user;
import 'Donation_Request_Details.dart';

// المخزن العام للطلبات


class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {


        return FutureBuilder(
          future:  SharedPref.getReqs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (!snapshot.hasData) {
              return Text("No user found");
            }

            List<Request> requests = snapshot.data!
                .where((req) => req.reqStatus != RequestStatus.fulfilled.name)
                .toList();
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false, // إزالة زر الرجوع التلقائي
                title: const Text(
                  'My Requests',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => setState(() {}),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Appointments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: requests.isEmpty
                          ? const Center(
                              child: Text(
                                "No donation requests yet.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final req = requests[index];
                                return _buildMyRequestCard(
                                  context,
                                 req: req,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
        );


  }

  Widget _buildMyRequestCard(
    BuildContext context, {
    required Request req
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.bloodBankName ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${req.date} • ${req.time}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req.bloodType ?? "",
                  style: const TextStyle(
                    color: Color(0xFFC4001D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationDetailsScreen(request: req),
                      ),
                    ).then((value) {
                      if (value == true) {
                        setState(() {}); // reload data
                      }
                    });
                    if (mounted) setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4001D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Donation Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
