import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';

import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/theme_manager.dart';

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
          future:  SharedPreferencesHelper.getReqs(),
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
                .where((req) => req.reqStatus != RequestStatus.fulfilled.name )
                .toList();
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cs = Theme.of(context).colorScheme;
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  'My Requests',
                  style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: cs.onSurface),
                    onPressed: () => setState(() {}),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Appointments',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: requests.isEmpty
                          ? Center(
                              child: Text(
                                "No donation requests yet.",
                                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
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
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${req.date} • ${req.time}",
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.redDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req.bloodType ?? "",
                  style: const TextStyle(
                    color: AppColors.redDark,
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
                    await Navigator.pushNamed(context, Routes.donorRequestDetailsRoute, arguments: req).then((value) {
                      if (value == true) {
                        setState(() {});
                      }
                    });
                    if (mounted) setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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
