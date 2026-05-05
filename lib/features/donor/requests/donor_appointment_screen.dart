import 'package:www/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/features/donor/requests/donor_confirm_donation_screen.dart';
import 'package:www/core/utiles/ThemeManager.dart';
import 'package:www/core/models/user.dart';

class BloodBanksScreen extends StatelessWidget {
  const BloodBanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder(
      future: UserService.getUsersByType('bloodBank'),
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

        final List<User> bloodBanks = snapshot.data!;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? null : Theme.of(context).scaffoldBackgroundColor,
              gradient: isDark ? const RadialGradient(
                center: Alignment(0, -0.5),
                radius: 1.2,
                colors: [Color(0xFF250A0A), Colors.black],
              ) : null,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: cs.onSurface,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.05),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Blood Banks',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: bloodBanks.length,
                      itemBuilder: (context, index) {
                        return _buildBankCard(context, bloodBanks[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildBankCard(BuildContext context, User bank) {
    final status = getAvailabilityStatus(bank.workingHours ?? "");
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.name ?? "",
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bank.address ?? "",
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: cs.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                bank.workingHours ?? "",
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (status == 'Open Now'
                      ? Colors.green
                      : status == 'Closing Soon'
                      ? Colors.orange
                      : status == 'Opening Soon'
                      ? Colors.blue
                      : Colors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Open Now'
                        ? Colors.green
                        : status == 'Closing Soon'
                        ? Colors.orange
                        : status == 'Opening Soon'
                        ? Colors.blue
                        : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.donorConfirmDonationRoute, arguments: bank);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Make Appointment',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String getAvailabilityStatus(String workingHours) {
    final cleaned = workingHours.replaceAll(' ', '');
    final parts = cleaned.split('-');

    if (parts.length != 2) return 'Closed';

    final from = int.tryParse(parts[0]);
    final to = int.tryParse(parts[1]);

    if (from == null || to == null) return 'Closed';

    final now = DateTime.now().hour-12;

    if (now >= from && now < to) {
      if (now == to - 1) {
        return 'Closing Soon';
      }
      return 'Open Now';
    }

    if (now == from - 1) {
      return 'Opening Soon';
    }

    return 'Closed';
  }
}
