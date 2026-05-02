import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/app_notification.dart';
import 'package:www/core/utiles/ThemeManager.dart';

class BloodBankNotifications extends StatefulWidget {
  const BloodBankNotifications({super.key});

  @override
  State<BloodBankNotifications> createState() => _BloodBankNotificationsState();
}

class _BloodBankNotificationsState extends State<BloodBankNotifications> {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationService.streamForReceiver(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.redDark));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: cs.onSurface)));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(child: Text("No notifications yet", style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationItem(
                context: context,
                title: notif.title ?? 'Notification',
                body: notif.body ?? '',
                time: _formatTimestamp(notif.timestamp),
                icon: notif.type == 'request_accepted_blood_bank' ? Icons.check_circle :
                      notif.type == 'request_rejected_blood_bank' ? Icons.cancel :
                      notif.type == 'emergency_approved_blood_bank' ? Icons.warning_amber_rounded :
                      Icons.info_outline,
                iconColor: notif.type == 'request_accepted_blood_bank' ? const Color(0xFF43A047) :
                           notif.type == 'request_rejected_blood_bank' ? AppColors.redDark :
                           notif.type == 'emergency_approved_blood_bank' ? const Color(0xFFFFB300) :
                           const Color(0xFF2196F3),
                isUnread: !notif.isRead,
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Notifications',
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.redDark),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            "Clear All",
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withValues(alpha: 0.1), height: 1),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required String title,
    required String body,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? (isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard) : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.redDark.withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.redDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
