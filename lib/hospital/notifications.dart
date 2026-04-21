import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // الخلفية الداكنة الموحدة
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader("TODAY"),
          _buildNotificationItem(
            title: "Urgent Request Accepted",
            body:
                "City General Blood Bank has accepted your STAT request for 4 units of B+.",
            time: "2 mins ago",
            icon: Icons.check_circle,
            iconColor: const Color(0xFF43A047), // أخضر
            isUnread: true,
          ),
          _buildNotificationItem(
            title: "Rider is Nearby",
            body: "Rider #22 is 500m away with your A- batch delivery.",
            time: "15 mins ago",
            icon: Icons.moped_rounded,
            iconColor: const Color.fromARGB(255, 196, 0, 29), // أحمر
            isUnread: true,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("EARLIER"),
          _buildNotificationItem(
            title: "System Update",
            body:
                "New feature added: You can now track live temperature of blood batches.",
            time: "5 hours ago",
            icon: Icons.info_outline,
            iconColor: const Color(0xFF2196F3), // أزرق
            isUnread: false,
          ),
          _buildNotificationItem(
            title: "Delivery Fulfilled",
            body:
                "Batch #8821 was successfully delivered and signed by Dr. Sarah.",
            time: "Yesterday",
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF888888), // رمادي
            isUnread: false,
          ),
        ],
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

  // --- عنوان القسم (TODAY / EARLIER) ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
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
