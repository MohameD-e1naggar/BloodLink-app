import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/models/blood_inventory.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({super.key});

  @override
  State<HospitalSearchScreen> createState() =>
      _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  String _selectedBloodType = 'A+';
  double _distanceRange = 25.0;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  Future<List<Map<String, dynamic>>> _loadBloodBanks() async {
    try {
      final bloodBanks = await UserService.getUsersByType(my_user.UserTypes.bloodBank.name);

      final List<Map<String, dynamic>> bloodBankData = [];

      for (final bank in bloodBanks) {
        final inventory = await InventoryService.get(bank.id!);

        final units = _getUnitsForBloodType(inventory, _selectedBloodType);
        final status = _getStatus(units);

        bloodBankData.add({
          'id': bank.id,
          'name': bank.name ?? 'Unknown Blood Bank',
          'address': bank.address ?? 'N/A',
          'units': units,
          'status': status,
          'workingHours': bank.workingHours ?? 'N/A',
        });
      }

      return bloodBankData;
    } catch (e) {
      return [];
    }
  }

  int _getUnitsForBloodType(Inventory? inventory, String bloodType) {
    if (inventory == null) return 0;

    switch (bloodType) {
      case 'A+':
        return inventory.aPos ?? 0;
      case 'A-':
        return inventory.aNeg ?? 0;
      case 'B+':
        return inventory.bPos ?? 0;
      case 'B-':
        return inventory.bNeg ?? 0;
      case 'O+':
        return inventory.oPos ?? 0;
      case 'O-':
        return inventory.oNeg ?? 0;
      case 'AB+':
        return inventory.abPos ?? 0;
      case 'AB-':
        return inventory.abNeg ?? 0;
      default:
        return 0;
    }
  }

  String _getStatus(int units) {
    if (units >= 10) {
      return 'high';
    } else if (units >= 3) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F0F),
      elevation: 0,
      title: const Text(
        'Blood Availability',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Column(
          children: [
            Row(
              children: [
                _buildTabItem("Find Stock", true),
                _buildTabItem("Map View", false),
                _buildTabItem("History", false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF555555),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 3,
            color: isActive
                ? const Color.fromARGB(255, 196, 0, 29)
                : const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: const Color(0xFF141414),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "SELECT BLOOD TYPE",
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _bloodTypes.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedBloodType == _bloodTypes[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBloodType = _bloodTypes[index]);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 55,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 196, 0, 29)
                          : const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _bloodTypes[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Search Radius",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  "${_distanceRange.toInt()} km",
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color.fromARGB(255, 196, 0, 29),
              inactiveTrackColor: const Color(0xFF2A2A2A),
              thumbColor: Colors.white,
              overlayColor: const Color.fromARGB(
                255,
                196,
                0,
                29,
              ).withOpacity(0.2),
            ),
            child: Slider(
              value: _distanceRange,
              min: 5,
              max: 100,
              onChanged: (val) => setState(() => _distanceRange = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadBloodBanks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final locations = snapshot.data ?? [];

        if (locations.isEmpty) {
          return const Center(
            child: Text(
              'No blood banks found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final item = locations[index];
            return _buildLocationCard(item);
          },
        );
      },
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> item) {
    Color statusColor;

    if (item['status'] == 'high') {
      statusColor = const Color(0xFF43A047);
    } else if (item['status'] == 'medium') {
      statusColor = Colors.orange;
    } else {
      statusColor = const Color.fromARGB(255, 196, 0, 29);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item['address'] ?? 'N/A',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['workingHours'] ?? 'N/A',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item['units']}",
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "UNITS",
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.directions_outlined,
                      size: 16,
                      color: Color(0xFF888888),
                    ),
                    label: const Text(
                      "Directions",
                      style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: const Color(0xFF2A2A2A)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: statusColor,
                    ),
                    label: Text(
                      "Contact",
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
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
