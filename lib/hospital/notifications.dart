import 'package:flutter/material.dart';
import 'package:www/Backend/FirestoreHandler.dart';
import 'package:www/Backend/models/AppNotification.dart';

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
      backgroundColor: const Color(0xFF0F0F0F), // الخلفية الداكنة الموحدة
      appBar: _buildAppBar(context),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationItem(
                title: notif.title ?? 'Notification',
                body: notif.body ?? '',
                time: _formatTimestamp(notif.timestamp),
                icon: notif.type == 'request_accepted_hospital' ? Icons.check_circle : 
                      notif.type == 'request_rejected_hospital' ? Icons.cancel :
                      notif.type == 'emergency_approved_hospital' ? Icons.warning_amber_rounded :
                      Icons.info_outline,
                iconColor: notif.type == 'request_accepted_hospital' ? const Color(0xFF43A047) :
                           notif.type == 'request_rejected_hospital' ? const Color.fromARGB(255, 196, 0, 29) :
                           notif.type == 'emergency_approved_hospital' ? const Color(0xFFFFB300) :
                           const Color(0xFF2196F3),
                isUnread: !notif.isRead,
              );
            },
          );
        },
      ),
    );
  }

  // --- الـ AppBar بنفس ستايل شاشة الـ History والـ Search ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFE53935)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text(
            "Clear All",
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFF2A2A2A), height: 1),
      ),
    );
  }



  // --- عنصر الإشعار الواحد ---
  Widget _buildNotificationItem({
    required String title,
    required String body,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF1A1A1A) : const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? const Color.fromARGB(255, 196, 0, 29).withOpacity(0.3)
              : const Color(0xFF2A2A2A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الإشعار داخل دائرة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          // محتوى الإشعار
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF444444),
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
