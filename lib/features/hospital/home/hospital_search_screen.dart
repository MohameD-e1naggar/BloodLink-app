import 'package:flutter/material.dart';
import 'package:www/core/services/firestore_service.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/models/blood_inventory.dart';
import 'package:www/core/utiles/theme_manager.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: Text(
        'Blood Availability',
        style: TextStyle(
          color: cs.onSurface,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 3,
            color: isActive
                ? AppColors.redDark
                : (isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "SELECT BLOOD TYPE",
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
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
                          ? AppColors.redDark
                          : (isDark ? const Color(0xFF1F1F1F) : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _bloodTypes[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
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
                Text(
                  "Search Radius",
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                ),
                Text(
                  "${_distanceRange.toInt()} km",
                  style: const TextStyle(
                    color: AppColors.redDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.redDark,
              inactiveTrackColor: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1),
              thumbColor: cs.onSurface,
              overlayColor: AppColors.redDark.withOpacity(0.2),
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
    final cs = Theme.of(context).colorScheme;
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
              style: TextStyle(color: cs.onSurface),
            ),
          );
        }

        final locations = snapshot.data ?? [];

        if (locations.isEmpty) {
          return Center(
            child: Text(
              'No blood banks found',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    if (item['status'] == 'high') {
      statusColor = const Color(0xFF43A047);
    } else if (item['status'] == 'medium') {
      statusColor = Colors.orange;
    } else {
      statusColor = AppColors.redDark;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item['name'],
              style: TextStyle(
                color: cs.onSurface,
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
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['workingHours'] ?? 'N/A',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
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
          Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.directions_outlined,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    label: Text(
                      "Directions",
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: isDark ? const Color(0xFF2A2A2A) : cs.onSurface.withOpacity(0.1)),
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
