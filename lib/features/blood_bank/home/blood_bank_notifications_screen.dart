import 'package:flutter/material.dart';

class BloodBankNotifications extends StatefulWidget {
  const BloodBankNotifications({super.key});

  @override
  State<BloodBankNotifications> createState() => _BloodBankNotificationsState();
}

class _BloodBankNotificationsState extends State<BloodBankNotifications> {
  final Map<String, int> _bloodStock = {
    'A+': 45,
    'A-': 12,
    'B+': 28,
    'B-': 5,
    'O+': 55,
    'O-': 8,
    'AB+': 25,
    'AB-': 3,
  };

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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.settings_input_component, color: Color(0xFFE53935)),
              SizedBox(width: 10),
              Text(
                'Stock Management',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Select Blood Type'),
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
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enter Units Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 196, 0, 29),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (selectedType != null && _amountController.text.isNotEmpty) {
                  int amount = int.tryParse(_amountController.text) ?? 0;
                  setState(() {
                    if (isAdding) {
                      _bloodStock[selectedType!] =
                          _bloodStock[selectedType!]! + amount;
                    } else {
                      _bloodStock[selectedType!] =
                          (_bloodStock[selectedType!]! - amount).clamp(0, 9999);
                    }
                  });
                  Navigator.pop(context);
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      filled: true,
      fillColor: const Color(0xFF0F0F0F),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 196, 0, 29),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
          ),
        ),
        title: const Text(
          'City Central Blood Bank',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Inventory',
              style: TextStyle(
                color: Colors.white,
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
                );
              },
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _showInventoryDialog,
              child: _buildActionBtn(
                'MANAGE INVENTORY',
                Icons.edit_calendar_rounded,
                const Color.fromARGB(255, 196, 0, 29),
              ),
            ),
            const SizedBox(height: 12),
            _buildOutlineBtn('CHECK EXPIRY UNITS', Icons.history_toggle_off),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodCard({
    required String type,
    required String count,
    required String status,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Units in stock',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2A2A2A),
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

  Widget _buildOutlineBtn(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
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
