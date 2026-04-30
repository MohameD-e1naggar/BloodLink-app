import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/cache/shared_preferences_helper.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/features/donor/requests/donor_request_screen.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Booked Successfully!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4001D),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirm Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bloodBank.name ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text('Select Date', style: TextStyle(color: Colors.grey)),
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
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d MMMM yyyy').format(selectedDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(Icons.calendar_month, color: Color(0xFFC4001D)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Select Time', style: TextStyle(color: Colors.grey)),
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
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) => setState(() => selectedTime = time),
                  selectedColor: const Color(0xFFC4001D),
                  backgroundColor: const Color(0xFF1A1A1A),
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
                  backgroundColor: const Color(0xFFC4001D),
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
