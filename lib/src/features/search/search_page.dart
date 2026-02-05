import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';
import 'package:med_shakthi/src/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allMedicines = [];
  List<Map<String, dynamic>> allDevices = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      // Load medicines
      final String medicinesCSV = await rootBundle.loadString(
        'assets/data/Medicine_Details.csv',
      );
      List<List<dynamic>> medicinesTable = const CsvToListConverter().convert(
        medicinesCSV,
      );

      if (medicinesTable.isNotEmpty) {
        List<String> headers = medicinesTable[0]
            .map((e) => e.toString())
            .toList();
        for (int i = 1; i < medicinesTable.length; i++) {
          Map<String, dynamic> medicine = {'type': 'medicine'};
          for (
            int j = 0;
            j < headers.length && j < medicinesTable[i].length;
            j++
          ) {
            medicine[headers[j]] = medicinesTable[i][j];
          }
          allMedicines.add(medicine);
        }
      }

      // Load devices
      final String devicesCSV = await rootBundle.loadString(
        'assets/data/medical_device_manuals_dataset.csv',
      );
      List<List<dynamic>> devicesTable = const CsvToListConverter().convert(
        devicesCSV,
      );

      if (devicesTable.isNotEmpty) {
        List<String> headers = devicesTable[0]
            .map((e) => e.toString())
            .toList();
        for (int i = 1; i < devicesTable.length; i++) {
          Map<String, dynamic> device = {'type': 'device'};
          for (
            int j = 0;
            j < headers.length && j < devicesTable[i].length;
            j++
          ) {
            device[headers[j]] = devicesTable[i][j];
          }
          allDevices.add(device);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
        searchQuery = '';
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchQuery = query.toLowerCase();
      searchResults = [];

      // Search in medicines
      for (var medicine in allMedicines) {
        final name = (medicine['Medicine Name'] ?? '').toString().toLowerCase();
        final manufacturer = (medicine['Manufacturer'] ?? '')
            .toString()
            .toLowerCase();
        final composition = (medicine['Composition'] ?? '')
            .toString()
            .toLowerCase();
        final uses = (medicine['Uses'] ?? '').toString().toLowerCase();

        if (name.contains(searchQuery) ||
            manufacturer.contains(searchQuery) ||
            composition.contains(searchQuery) ||
            uses.contains(searchQuery)) {
          searchResults.add(medicine);
        }
      }

      // Search in devices
      for (var device in allDevices) {
        final deviceName = (device['Device_Name'] ?? '')
            .toString()
            .toLowerCase();
        final manufacturer = (device['Manufacturer'] ?? '')
            .toString()
            .toLowerCase();
        final modelNumber = (device['Model_Number'] ?? '')
            .toString()
            .toLowerCase();

        if (deviceName.contains(searchQuery) ||
            manufacturer.contains(searchQuery) ||
            modelNumber.contains(searchQuery)) {
          searchResults.add(device);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: performSearch,
            decoration: InputDecoration(
              hintText: 'Search medicines & devices...',
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6)),
                      onPressed: () {
                        _searchController.clear();
                        performSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!isSearching || searchQuery.isEmpty) {
      return _buildSuggestions();
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No results found for "$searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${searchResults.length} results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final item = searchResults[index];
              if (item['type'] == 'medicine') {
                return _buildMedicineCard(item);
              } else {
                return _buildDeviceCard(item);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Paracetamol'),
              _buildSuggestionChip('Thermometer'),
              _buildSuggestionChip('Blood Pressure'),
              _buildSuggestionChip('Oximeter'),
              _buildSuggestionChip('Antibiotics'),
              _buildSuggestionChip('Vitamins'),
              _buildSuggestionChip('Glucose Monitor'),
              _buildSuggestionChip('Pain Relief'),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentSearchItem('Aspirin'),
          _buildRecentSearchItem('Digital Thermometer'),
          _buildRecentSearchItem('Vitamin D'),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return InkWell(
      onTap: () {
        _searchController.text = label;
        performSearch(label);
      },
      child: Chip(
        label: Text(label),
        backgroundColor: Theme.of(context).cardColor,
        side: BorderSide(color: Theme.of(context).dividerColor),
        labelStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildRecentSearchItem(String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.history, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6)),
      title: Text(text),
      onTap: () {
        _searchController.text = text;
        performSearch(text);
      },
      trailing: IconButton(
        icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMedicineDetails(medicine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  medicine['Image URL'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200],
                      child: Icon(
                        Icons.medical_services,
                        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.4),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine['Medicine Name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine['Manufacturer'] ?? '',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${(medicine['Excellent Review %'] ?? 0) / 20}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${medicine['Price'] ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A9CA0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Wishlist button
              Consumer<WishlistService>(
                builder: (context, wishlistService, child) {
                  final medicineId =
                      '${medicine['Medicine Name']}_${medicine['Manufacturer']}'
                          .replaceAll(' ', '_');
                  final isInWishlist = wishlistService.isInWishlist(medicineId);
                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: () {
                      if (isInWishlist) {
                        wishlistService.removeFromWishlist(medicineId);
                      } else {
                        final wishlistItem = WishlistItem(
                          id: medicineId,
                          name: medicine['Medicine Name'] ?? 'Unknown',
                          price:
                              double.tryParse(
                                medicine['Price']?.toString() ?? '0',
                              ) ??
                              0.0,
                          image: medicine['Image URL'] ?? '',
                        );
                        wishlistService.addToWishlist(wishlistItem);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDeviceDetails(device),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 40,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEVICE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      device['Device_Name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device['Manufacturer'] ?? '',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (device['Model_Number'] != null &&
                        device['Model_Number'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Model: ${device['Model_Number']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(Map<String, dynamic> medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        medicine['Image URL'] ?? '',
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.medical_services,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    medicine['Medicine Name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    medicine['Manufacturer'] ?? 'Unknown Manufacturer',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Composition',
                    medicine['Composition'] ?? 'N/A',
                    Icons.science,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Uses',
                    medicine['Uses'] ?? 'N/A',
                    Icons.healing,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Side Effects',
                    medicine['Side_effects'] ?? 'N/A',
                    Icons.warning_amber_rounded,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeviceDetails(Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    device['Device_Name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device['Manufacturer'] ?? 'Unknown Manufacturer',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (device['Model_Number'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Model: ${device['Model_Number']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Device Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'This is a medical device. Please consult with healthcare professionals for proper usage and guidance.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
