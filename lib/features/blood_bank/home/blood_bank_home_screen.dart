import 'package:firebase_auth/firebase_auth.dart';
import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:www/core/models/blood_inventory.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/app_notification.dart';

import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/utiles/ThemeManager.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.settings_input_component, color: AppColors.redDark),
              SizedBox(width: 10),
              Text(
                'Stock Management',
                style: TextStyle(color: cs.onSurface, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : AppColors.lightCard,
                style: TextStyle(color: cs.onSurface),
                decoration: _inputDecoration('Select Blood Type', context),
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
                style: TextStyle(color: cs.onSurface),
                decoration: _inputDecoration('Enter Units Amount', context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (selectedType != null && _amountController.text.isNotEmpty) {

                  int amount = int.tryParse(_amountController.text) ?? 0;

                  final inventory = await InventoryService.get(uid);
                  if (inventory == null) return;

                  Map<String, int> updated = inventory.toBloodMap();

                  if (isAdding) {
                    updated[selectedType!] = (updated[selectedType!] ?? 0) + amount;
                  } else {
                    updated[selectedType!] =
                        ((updated[selectedType!] ?? 0) - amount).clamp(0, 9999);
                  }

                  await InventoryService.updateInventory(uid, Inventory(
                    aPos: updated['A+'],
                    aNeg: updated['A-'],
                    bPos: updated['B+'],
                    bNeg: updated['B-'],
                    oPos: updated['O+'],
                    oNeg: updated['O-'],
                    abPos: updated['AB+'],
                    abNeg: updated['AB-'],
                  ));

                  await NotificationService.create(AppNotification(
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

  InputDecoration _inputDecoration(String label, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.redDark),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F0F0F) : AppColors.lightCard,
    );
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<List<dynamic>> loadData() {
    return Future.wait([
      UserService.getUser(uid) ,
      InventoryService.get(uid),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return ValueListenableBuilder<bool>(
      valueListenable: refreshHome,
      builder: (context, value, _) {
        return FutureBuilder(
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
            var inventory = snapshot.data![1] as Inventory;
            var user = snapshot.data![0] as my_user.User;

            _bloodStock = inventory.toBloodMap();

             SharedPreferencesHelper.setUser(user);

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.redDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
                  ),
                ),
                title: Text(
                  user.name ?? '',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: cs.onSurface,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.bloodBankNotificationsRoute,
                        arguments: uid,
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
                    Text(
                      'Live Inventory',
                      style: TextStyle(
                        color: cs.onSurface,
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
                          context: context,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: _showInventoryDialog,
                      child: _buildActionBtn(
                        'MANAGE INVENTORY',
                        Icons.edit_calendar_rounded,
                        AppColors.redDark,
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
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: TextStyle(
                  color: cs.onSurface,
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
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Units in stock',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 10),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1),
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

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
        title: Text(
          'Notifications',
          style: TextStyle(color: cs.onSurface),
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationService.streamForReceiver(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.redDark));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: cs.onSurface)));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(child: Text("No notifications yet", style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))));
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
                  color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      notif.type == 'request_incoming' ? Icons.local_hospital :
                      notif.type == 'request_fulfilled' ? Icons.check_circle :
                      notif.type == 'request_approved' ? Icons.thumb_up :
                      Icons.info_outline,
                      color: AppColors.redDark
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.title ?? 'Notification',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.body ?? '',
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTimestamp(notif.timestamp),
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10),
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
