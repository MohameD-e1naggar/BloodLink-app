import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:www/Backend/models/Inventory.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/Backend/models/AppNotification.dart';

import '../Backend/FirestoreHandler.dart';
import '../Backend/cash/shared_pref.dart';
import '../Backend/models/User.dart' as my_user;

ValueNotifier<bool> refreshHome = ValueNotifier(false);
class BloodBankHomeScreen extends StatefulWidget {

  const BloodBankHomeScreen({super.key});

  @override
  State<BloodBankHomeScreen> createState() => _BloodBankHomeScreenState();
}

class _BloodBankHomeScreenState extends State<BloodBankHomeScreen> {
  Map<String, int> _bloodStock = {};
  late var uid;

  Map<String, dynamic> _getStatus(int units) {
    if (units <= 10) {
      return {
        'label': 'CRITICAL',
        'color': const Color.fromARGB(255, 196, 0, 29),
        'progress': 0.2,
      };
    } else if (units <= 25) {
      return {'label': 'NORMAL', 'color': Colors.orange, 'progress': 0.5};
    } else {
      return {'label': 'STABLE', 'color': Colors.green, 'progress': 0.8};
    }
  }

  void _showInventoryDialog() {
    String? selectedType;
    final TextEditingController _amountController = TextEditingController();
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.settings_input_component, color: Color(0xFFE53935)),
              SizedBox(width: 10),
              const Text(
                'Stock Management',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Select Blood Type'),
                items: _bloodStock.keys
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) => selectedType = val,
              ),
              const SizedBox(height: 20),
              ToggleButtons(
                isSelected: [isAdding, !isAdding],
                onPressed: (index) =>
                    setDialogState(() => isAdding = index == 0),
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: isAdding
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                color: Colors.grey,
                constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
                children: const [Text('ADD'), Text('REMOVE')],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter Units Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 196, 0, 29),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (selectedType != null && _amountController.text.isNotEmpty) {

                  int amount = int.tryParse(_amountController.text) ?? 0;

                  final ref = FirestoreHandler.getInventoryDoc(uid);
                  final doc = await ref.get();
                  final inventory = doc.data()!;

                  Map<String, int> updated = inventory.toBloodMap();

                  if (isAdding) {
                    updated[selectedType!] =
                        (updated[selectedType!] ?? 0) + amount;
                  } else {
                    updated[selectedType!] =
                        ((updated[selectedType!] ?? 0) - amount).clamp(0, 9999);
                  }

                  await ref.set(Inventory(
                    aPos: updated['A+'],
                    aNeg: updated['A-'],
                    bPos: updated['B+'],
                    bNeg: updated['B-'],
                    oPos: updated['O+'],
                    oNeg: updated['O-'],
                    abPos: updated['AB+'],
                    abNeg: updated['AB-'],
                  ));

                  await FirestoreHandler.createNotification(AppNotification(
                    receiverId: uid,
                    title: 'Inventory Updated',
                    body: isAdding ? 'Added $amount units to $selectedType.' : 'Removed $amount units from $selectedType.',
                    timestamp: DateTime.now().toIso8601String(),
                    type: 'inventory_update',
                  ));

                  Navigator.pop(context);

                  setState(() {});
                }
              },
              child: const Text(
                'UPDATE STOCK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      filled: true,
      fillColor: const Color(0xFF0F0F0F),
    );
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }


  Future<List<dynamic>> loadData() {
    return Future.wait([
      FirestoreHandler.getUser(uid) ,
      FirestoreHandler.getInventory(uid),
    ]);
  }


  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<bool>(
      valueListenable: refreshHome,
      builder: (context, value, _) {
        return FutureBuilder(
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
            var inventory = snapshot.data![1] as Inventory;
            var user = snapshot.data![0] as my_user.User;
        
            _bloodStock = inventory.toBloodMap();
        
             SharedPref.setUser(user);
        
        
            return Scaffold(
              backgroundColor: const Color(0xFF0F0F0F),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 196, 0, 29),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
                  ),
                ),
                title: Text(
                  user.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsScreen(uid: uid),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Inventory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _bloodStock.length,
                      itemBuilder: (context, index) {
                        String type = _bloodStock.keys.elementAt(index);
                        int count = _bloodStock[type]!;
                        var status = _getStatus(count);
                        return _buildBloodCard(
                          type: type,
                          count: count.toString(),
                          status: status['label'],
                          color: status['color'],
                          progress: status['progress'],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // زر التحكم بالمخزون فقط
                    InkWell(
                      onTap: _showInventoryDialog,
                      child: _buildActionBtn(
                        'MANAGE INVENTORY',
                        Icons.edit_calendar_rounded,
                        const Color.fromARGB(255, 196, 0, 29),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildBloodCard({
    required String type,
    required String count,
    required String status,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Units in stock',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2A2A2A),
            color: color,
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  final String uid;
  const NotificationsScreen({super.key, required this.uid});

  String _formatTimestamp(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.parse(isoString);
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: FirestoreHandler.getNotificationsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet", style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Row(
                  children: [
                    Icon(
                      notif.type == 'request_incoming' ? Icons.local_hospital :
                      notif.type == 'request_fulfilled' ? Icons.check_circle :
                      notif.type == 'request_approved' ? Icons.thumb_up :
                      Icons.info_outline, 
                      color: const Color(0xFFE53935)
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.title ?? 'Notification',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.body ?? '',
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTimestamp(notif.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
