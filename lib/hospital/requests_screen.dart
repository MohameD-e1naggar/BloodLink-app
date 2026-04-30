import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/Backend/FirestoreHandler.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedFilter = 'all'; // all, pending, approved

  Future<List<Request>> _loadRequests() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final collection = FirestoreHandler.getReqCollection();

    // Get all requests sent by this hospital (all statuses)
    final querySnapshot = await collection
        .where('hospitalId', isEqualTo: userId)
        .get();

    final requests = querySnapshot.docs.map((doc) => doc.data()).toList();

    // Filter based on selected filter
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

    await FirestoreHandler.deleteRequest(req.id!);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
          automaticallyImplyLeading: false,
        title: const Text(
          "Blood Requests",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
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
          // Requests list
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
                      style: const TextStyle(color: Colors.white),
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
                          color: Colors.grey.withOpacity(0.5),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No requests yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: const Color(0xFFC4001D),
      side: BorderSide(
        color: isSelected ? const Color(0xFFC4001D) : Colors.grey,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
      ),
    );
  }

  Widget _buildRequestCard(Request req) {
    final isEmergency = req.urgency == Urgency.critical.name;
    final status = req.reqStatus;

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isEmergency
                      ? Colors.red.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
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
                        "Blood Bank: ${req.bloodBankName ?? 'Unknown'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${req.units} Units • ${req.time ?? 'N/A'}",
                        style: const TextStyle(
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
            const Divider(color: Color(0xFF333333)),
            // Status display and cancel button for pending only
            if (status == RequestStatus.pending.name)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Waiting for blood bank response...",
                      style: TextStyle(
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Blood bank approved your request",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
}
