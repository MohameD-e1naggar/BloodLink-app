import 'package:flutter/material.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({
    super.key,
    required List<Map<String, dynamic>> requestData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 24),
            _buildClinicalNotes(),
            const SizedBox(height: 24),
            _buildMatchingStatus(),
            const SizedBox(height: 24),
            _buildLogisticsProgress(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Request Details',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // ─── Hero Card ───────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A1515)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: timestamp + CRITICAL badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Requested 12m ago',
                style: TextStyle(color: Color(0xFFE57373), fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 196, 0, 29),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 6),
                    Text(
                      'CRITICAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Blood type
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'O-',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(width: 14),
              Text(
                'Blood Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Units + Urgency row
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFFE53935),
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                '4 Units',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 18, color: const Color(0xFF3A3A3A)),
              const SizedBox(width: 20),
              const Icon(Icons.emergency, color: Color(0xFFE53935), size: 18),
              const SizedBox(width: 6),
              const Text(
                'Emergency Surgery',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Clinical Notes ───────────────────────────────────────────────────────────
  Widget _buildClinicalNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.description_outlined,
          'CLINICAL NOTES',
          const Color(0xFFE57373),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: const Text(
            'Patient ID: . Scheduled for Emergency Surgery at 14:00. High urgency required for',
            style: TextStyle(
              color: Color(0xFFBBBBBB),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Matching Status ──────────────────────────────────────────────────────────
  Widget _buildMatchingStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.settings_outlined,
          'MATCHING STATUS',
          const Color(0xFFE57373),
        ),
        const SizedBox(height: 12),
        // Blood bank card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C0A0A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A1515)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1515),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'City Central Blood Bank',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF888888),
                        size: 13,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '2.4 km away',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Donor: Marcus Johnson
        _buildDonorCard(
          name: 'Marcus Johnson',
          role: 'O- DONOR',
          status: 'CONFIRMED',
          statusColor: const Color(0xFF43A047),
          avatarColor: const Color(0xFF5D4037),
          initials: 'MJ',
        ),
        const SizedBox(height: 10),
        // Donor: Sarah Williams
        _buildDonorCard(
          name: 'Sarah Williams',
          role: 'O- DONOR',
          status: 'PENDING',
          statusColor: const Color(0xFFFFB300),
          avatarColor: const Color(0xFF4A148C),
          initials: 'SW',
        ),
      ],
    );
  }

  Widget _buildDonorCard({
    required String name,
    required String role,
    required String status,
    required Color statusColor,
    required Color avatarColor,
    required String initials,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Logistics Progress ───────────────────────────────────────────────────────
  Widget _buildLogisticsProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.local_shipping_outlined,
          'LOGISTICS PROGRESS',
          const Color(0xFFE57373),
        ),
        const SizedBox(height: 16),
        _buildTimelineStep(
          title: 'Request Created',
          subtitle: 'Oct 24, 11:30 AM',
          isCompleted: true,
          isActive: false,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Matched with Bank',
          subtitle: 'Oct 24, 11:35 AM',
          isCompleted: true,
          isActive: false,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'In Transit',
          subtitle: 'Estimated arrival: 8 mins',
          isCompleted: false,
          isActive: true,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Fulfilled',
          subtitle: '',
          isCompleted: false,
          isActive: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final Color dotColor = isCompleted
        ? const Color.fromARGB(255, 196, 0, 29)
        : isActive
        ? const Color.fromARGB(255, 196, 0, 29)
        : const Color(0xFF2A2A2A);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color.fromARGB(255, 196, 0, 29)
                        : const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isActive
                        ? Icons.circle
                        : Icons.circle_outlined,
                    color: isCompleted || isActive
                        ? Colors.white
                        : const Color(0xFF3A3A3A),
                    size: isActive ? 10 : 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? const Color.fromARGB(255, 196, 0, 29)
                          : const Color(0xFF2A2A2A),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive
                          ? const Color.fromARGB(255, 196, 0, 29)
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────────
  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE57373),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
