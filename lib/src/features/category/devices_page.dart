import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Map<String, dynamic>> devices = [];
  List<Map<String, dynamic>> filteredDevices = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  // Device categories with their icons and colors
  final Map<String, Map<String, dynamic>> deviceCategories = {
    'Thermometer': {
      'icon': Icons.thermostat,
      'color': Color(0xFFFF9800),
      'bgColor': Color(0xFFFFE0B2),
    },
    'Oximeter': {
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
      'bgColor': Color(0xFFFCE4EC),
    },
    'Weighing Scale': {
      'icon': Icons.monitor_weight,
      'color': Color(0xFF9C27B0),
      'bgColor': Color(0xFFF3E5F5),
    },
    'Supplements': {
      'icon': Icons.medication,
      'color': Color(0xFF4CAF50),
      'bgColor': Color(0xFFE8F5E9),
    },
    'Surgical': {
      'icon': Icons.medical_services,
      'color': Color(0xFF2196F3),
      'bgColor': Color(0xFFE3F2FD),
    },
    'Blood Pressure Monitor': {
      'icon': Icons.monitor_heart,
      'color': Color(0xFFFF5722),
      'bgColor': Color(0xFFFFE0B2),
    },
    'Blood Glucose Monitor': {
      'icon': Icons.bloodtype,
      'color': Color(0xFFE91E63),
      'bgColor': Color(0xFFFCE4EC),
    },
    'Pulse Oximeter': {
      'icon': Icons.favorite_border,
      'color': Color(0xFFFF9800),
      'bgColor': Color(0xFFFFE0B2),
    },
    'Ventilator': {
      'icon': Icons.air,
      'color': Color(0xFF00BCD4),
      'bgColor': Color(0xFFE0F7FA),
    },
    'Defibrillator': {
      'icon': Icons.electric_bolt,
      'color': Color(0xFFF44336),
      'bgColor': Color(0xFFFFEBEE),
    },
  };

  @override
  void initState() {
    super.initState();
    loadDevicesFromCSV();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadDevicesFromCSV() async {
    try {
      final String csvString = await rootBundle.loadString(
        'assets/data/medical_device_manuals_dataset.csv',
      );

      List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvString,
      );

      if (csvTable.isNotEmpty) {
        List<String> headers = csvTable[0].map((e) => e.toString()).toList();

        // Load all individual devices
        List<Map<String, dynamic>> deviceList = [];

        for (int i = 1; i < csvTable.length; i++) {
          Map<String, dynamic> device = {};
          for (int j = 0; j < headers.length && j < csvTable[i].length; j++) {
            device[headers[j]] = csvTable[i][j];
          }
          deviceList.add(device);
        }

        setState(() {
          devices = deviceList;
          filteredDevices = deviceList;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading CSV: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterDevices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDevices = devices;
      } else {
        final lowerQuery = query.toLowerCase();
        filteredDevices = devices.where((device) {
          final deviceName = (device['Device_Name'] ?? '')
              .toString()
              .toLowerCase();
          final manufacturer = (device['Manufacturer'] ?? '')
              .toString()
              .toLowerCase();
          final modelNumber = (device['Model_Number'] ?? '')
              .toString()
              .toLowerCase();
          return deviceName.contains(lowerQuery) ||
              manufacturer.contains(lowerQuery) ||
              modelNumber.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterDevices,
                decoration: InputDecoration(
                  hintText: 'Search devices...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              )
            : const Text(
                'Devices & Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  filteredDevices = devices;
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredDevices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isSearching && _searchController.text.isNotEmpty
                        ? 'No devices found'
                        : 'No devices available',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  final device = filteredDevices[index];
                  final deviceName =
                      device['Device_Name']?.toString() ?? 'Unknown';
                  final modelNumber = device['Model_Number']?.toString() ?? '';
                  final manufacturer = device['Manufacturer']?.toString() ?? '';

                  // Get category info or use default
                  final categoryInfo =
                      deviceCategories[deviceName] ??
                      {
                        'icon': Icons.medical_services,
                        'color': Color(0xFF607D8B),
                        'bgColor': Color(0xFFECEFF1),
                      };

                  return _buildDeviceCard(
                    deviceName,
                    modelNumber.isNotEmpty
                        ? 'Model: $modelNumber'
                        : manufacturer,
                    categoryInfo['icon'],
                    categoryInfo['color'],
                    categoryInfo['bgColor'],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildDeviceCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 35, color: iconColor),
            ),
            const SizedBox(height: 16),
            // Device name
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // SKU count
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
