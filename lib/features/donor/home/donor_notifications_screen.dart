import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:www/core/services/notification_service.dart';
import 'package:www/core/models/app_notification.dart';
import 'package:www/core/utiles/theme_manager.dart';

class DonorNotificationsScreen extends StatefulWidget {
  const DonorNotificationsScreen({super.key});

  @override
  State<DonorNotificationsScreen> createState() => _DonorNotificationsScreenState();
}

class _DonorNotificationsScreenState extends State<DonorNotificationsScreen> {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Just now';
    try {
      final dt = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
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
          child: uid.isEmpty
              ? Center(
                  child: Text(
                    "No authenticated user found",
                    style: TextStyle(color: cs.onSurface),
                  ),
                )
              : StreamBuilder<List<AppNotification>>(
                  stream: NotificationService.streamForReceiver(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.redDark),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: TextStyle(color: cs.onSurface),
                        ),
                      );
                    }
                    final notifications = snapshot.data ?? [];
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              color: cs.onSurface.withValues(alpha: 0.3),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No notifications yet",
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _buildNotificationCard(notif, context);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          onPressed: () {
            if (uid.isNotEmpty) {
              NotificationService.deleteAllForReceiver(uid);
            }
          },
          child: Text(
            "Clear All",
            style: TextStyle(
              color: AppColors.redDark.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withValues(alpha: 0.1),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    // Custom coloring and icons based on notification types
    final bool isUnread = !notif.isRead;
    IconData icon = Icons.info_outline;
    Color iconColor = const Color(0xFF2196F3);

    if (notif.type == 'request_accepted' || notif.type == 'emergency_approved_hospital' || notif.type == 'request_accepted_donor') {
      icon = Icons.check_circle;
      iconColor = const Color(0xFF43A047);
    } else if (notif.type == 'request_rejected' || notif.type == 'emergency_cancelled' || notif.type == 'request_rejected_donor') {
      icon = Icons.cancel;
      iconColor = AppColors.redDark;
    } else if (notif.type == 'inventory_update' || notif.type == 'blood_request_nearby') {
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFFFB300);
    } else if (notif.type == 'request_sent_donor') {
      icon = Icons.send_rounded;
      iconColor = const Color(0xFF2196F3);
    }

    return Dismissible(
      key: Key(notif.id ?? notif.timestamp ?? DateTime.now().toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.redDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (notif.id != null) {
          NotificationService.delete(notif.id!);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (isUnread && notif.id != null) {
            NotificationService.markAsRead(notif.id!);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread
                ? (isDark ? const Color(0xFF1F1F1F) : AppColors.lightCard)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? AppColors.redDark.withValues(alpha: 0.3)
                  : (isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withValues(alpha: 0.1)),
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: AppColors.redDark.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
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
                        Expanded(
                          child: Text(
                            notif.title ?? 'Notification',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
                      notif.body ?? '',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notif.timestamp),
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
        ),
      ),
    );
  }
}
