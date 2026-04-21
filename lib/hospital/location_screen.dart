import 'package:flutter/material.dart';

class HospitalLocationScreen extends StatefulWidget {
  const HospitalLocationScreen({super.key});

  @override
  State<HospitalLocationScreen> createState() => _HospitalLocationScreenState();
}

class _HospitalLocationScreenState extends State<HospitalLocationScreen> {
  // بيانات المحافظات والمدن
  final Map<String, List<String>> egyptData = {
    "القاهرة": [
      "مصر الجديدة",
      "مدينة نصر",
      "المعادي",
      "وسط البلد",
      "التجمع الخامس",
    ],
    "الجيزة": ["الدقي", "المهندسين", "الهرم", "6 أكتوبر", "الشيخ زايد"],
    "الإسكندرية": ["سموحة", "محطة الرمل", "سيدي جابر", "جليم", "العجمي"],
  };

  String? selectedGovernorate;
  String? selectedCity;
  List<String> cities = [];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF120808) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hospital Location',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الترحيبي
              const Text(
                'Find Nearest Hospital',
                style: TextStyle(
                  color: const Color.fromARGB(255, 196, 0, 29),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select your area to show available hospitals in our network.',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),

              // اختيار المحافظة
              _buildLabel("Governorate"),
              _buildDropdown(
                hint: "Select Governorate",
                value: selectedGovernorate,
                items: egyptData.keys.toList(),
                onChanged: (val) {
                  setState(() {
                    selectedGovernorate = val;
                    cities = egyptData[val]!;
                    selectedCity =
                        null; // إعادة تعيين المدينة عند تغيير المحافظة
                  });
                },
              ),

              const SizedBox(height: 24),

              // اختيار المدينة
              _buildLabel("City / Area"),
              _buildDropdown(
                hint: "Select Area",
                value: selectedCity,
                items: cities,
                enabled: selectedGovernorate != null,
                onChanged: (val) {
                  setState(() {
                    selectedCity = val;
                  });
                },
              ),

              const SizedBox(height: 60),

              // زر البحث
              _buildSubmitButton(),

              const SizedBox(height: 20),

              // تنبيه بسيط
              Center(
                child: Text(
                  'We only show hospitals registered with BloodLink',
                  style: TextStyle(
                    color: isDark ? Colors.white12 : Colors.black12,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويلجت العنوان الصغير فوق الدروب داون
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: const Color.fromARGB(255, 196, 0, 29),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ويلجت الـ Dropdown الموحدة
  Widget _buildDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1414), // اللون الغامق الموحد للتطبيق
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: enabled
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1414),
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: enabled
                ? const Color.fromARGB(255, 196, 0, 29)
                : Colors.white10,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  // زر الإرسال
  Widget _buildSubmitButton() {
    bool isReady = selectedCity != null;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isReady
            ? () {
                // هنا نضع الكود الذي سينقلنا لشاشة النتائج
                print("Searching in $selectedCity, $selectedGovernorate");
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 196, 0, 29),
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isReady ? 4 : 0,
        ),
        child: Text(
          'Show Nearby Hospitals',
          style: TextStyle(
            color: isReady ? Colors.white : Colors.white24,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
