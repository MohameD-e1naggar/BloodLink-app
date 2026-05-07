import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/features/donor/requests/donor_request_screen.dart';
import 'package:www/core/utiles/theme_manager.dart';

class MakeAppointmentScreen extends StatefulWidget {
  final my_user.User bloodBank;
  const MakeAppointmentScreen({super.key, required this.bloodBank});

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = "10:00 AM";

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  String _formatTime(int hour) {
    if (hour < 12) {
      return '${_twoDigits(hour)}:00 AM';
    } else if (hour == 12) {
      return '12:00 PM';
    } else {
      return '${_twoDigits(hour - 12)}:00 PM';
    }
  }
  List<String> generateTimes(String workingHours) {
    final cleaned = workingHours.replaceAll(' ', '');
    final parts = cleaned.split('-');

    if (parts.length != 2) return [];

    final from = int.tryParse(parts[0]);
    final to = int.tryParse(parts[1]);

    if (from == null || to == null) return [];

    List<String> times = [];

    for (int i = from; i <= to; i++) {
      times.add(_formatTime(i));
    }

    return times;
  }

  void _confirmBooking() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    my_user.User? user = await SharedPreferencesHelper.getUser();
    var bloodType = user?.bloodType ?? "";
    await RequestService.create(Request(
      bloodBankId: widget.bloodBank.id,
      donorId: uid,
      time: selectedTime,
      date: selectedDate.toIso8601String().split('T').first,
      bloodBankName: widget.bloodBank.name,
      reqStatus: RequestStatus.pending.name,
      reqSender: ReqSender.donor.name,
      urgency: Urgency.normal.name,
      bloodType: bloodType,
    ));

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text(
              'Booked Successfully!',
              style: TextStyle(color: cs.onSurface, fontSize: 18),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redDark,
              ),
              child: Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Confirm Appointment', style: TextStyle(color: cs.onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bloodBank.name ?? "",
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text('Select Date', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d MMMM yyyy').format(selectedDate),
                      style: TextStyle(color: cs.onSurface),
                    ),
                    const Icon(Icons.calendar_month, color: AppColors.redDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text('Select Time', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: generateTimes(widget.bloodBank.workingHours ?? "").map((time) {
                bool isSelected = selectedTime == time;
                return ChoiceChip(
                  label: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) => setState(() => selectedTime = time),
                  selectedColor: AppColors.redDark,
                  backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redDark,
                ),
                child: const Text(
                  'Confirm Appointment',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
