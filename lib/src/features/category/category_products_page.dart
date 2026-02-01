import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:med_shakthi/src/features/wishlist/presentation/screens/wishlist_page.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';
import 'package:med_shakthi/src/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:provider/provider.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Map<String, dynamic>> medicines = [];
  List<Map<String, dynamic>> filteredMedicines = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadMedicinesFromCSV();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadMedicinesFromCSV() async {
    try {
      // Load the CSV file from assets
      final String csvString =
          await rootBundle.loadString('assets/data/Medicine_Details.csv');

      // Parse CSV
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);

      // Convert to list of maps (skip header row)
      List<Map<String, dynamic>> medicineList = [];
      
      if (csvTable.isNotEmpty) {
        List<String> headers = csvTable[0].map((e) => e.toString()).toList();
        
        for (int i = 1; i < csvTable.length; i++) {
          Map<String, dynamic> medicine = {};
          for (int j = 0; j < headers.length && j < csvTable[i].length; j++) {
            medicine[headers[j]] = csvTable[i][j];
          }
          medicineList.add(medicine);
        }
      }

      setState(() {
        medicines = medicineList;
        filteredMedicines = medicineList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading CSV: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMedicines = medicines;
      } else {
        final lowerQuery = query.toLowerCase();
        filteredMedicines = medicines.where((medicine) {
          final name = (medicine['Medicine Name'] ?? '').toString().toLowerCase();
          final manufacturer = (medicine['Manufacturer'] ?? '').toString().toLowerCase();
          final composition = (medicine['Composition'] ?? '').toString().toLowerCase();
          return name.contains(lowerQuery) ||
              manufacturer.contains(lowerQuery) ||
              composition.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterMedicines,
                decoration: InputDecoration(
                  hintText: 'Search medicines...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              )
            : Text(widget.categoryName),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  filteredMedicines = medicines;
                }
              });
            },
          ),
          // Wishlist icon at top right
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredMedicines.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isSearching && _searchController.text.isNotEmpty
                            ? 'No medicines found'
                            : 'No medicines available',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = filteredMedicines[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showMedicineDetails(medicine);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Medicine Image with heart icon
                              Expanded(
                                child: Stack(
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          medicine['Image URL'] ?? '',
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.medical_services,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Heart icon for wishlist
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Consumer<WishlistService>(
                                        builder: (context, wishlistService, child) {
                                          // Create a unique ID for this medicine
                                          final medicineId = '${medicine['Medicine Name']}_${medicine['Manufacturer']}'.replaceAll(' ', '_');
                                          final isInWishlist = wishlistService.isInWishlist(medicineId);
                                          
                                          return GestureDetector(
                                            onTap: () {
                                              if (isInWishlist) {
                                                wishlistService.removeFromWishlist(medicineId);
                                              } else {
                                                // Convert medicine to WishlistItem
                                                final wishlistItem = WishlistItem(
                                                  id: medicineId,
                                                  name: medicine['Medicine Name'] ?? 'Unknown',
                                                  price: double.tryParse(medicine['Price']?.toString() ?? '0') ?? 0.0,
                                                  image: medicine['Image URL'] ?? '',
                                                );
                                                wishlistService.addToWishlist(wishlistItem);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                isInWishlist ? Icons.favorite : Icons.favorite_border,
                                                color: isInWishlist ? Colors.red : Colors.grey[700],
                                                size: 22,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Medicine Name
                              Text(
                                medicine['Medicine Name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Category/Manufacturer
                              Text(
                                medicine['Manufacturer'] ?? 'Devices',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Rating
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(medicine['Excellent Review %'] ?? 0) / 20}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Price and Add Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '₹${medicine['Price'] ?? '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Add Button
                                  InkWell(
                                    onTap: () {
                                      // Add to cart functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${medicine['Medicine Name']} added to cart',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 32,
                                      width: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5A9CA0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                  // Medicine Image
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
                  // Medicine Name
                  Text(
                    medicine['Medicine Name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Manufacturer
                  Text(
                    medicine['Manufacturer'] ?? 'Unknown Manufacturer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Composition
                  _buildDetailSection(
                    'Composition',
                    medicine['Composition'] ?? 'N/A',
                    Icons.science,
                  ),
                  const SizedBox(height: 16),
                  // Uses
                  _buildDetailSection(
                    'Uses',
                    medicine['Uses'] ?? 'N/A',
                    Icons.healing,
                  ),
                  const SizedBox(height: 16),
                  // Side Effects
                  _buildDetailSection(
                    'Side Effects',
                    medicine['Side_effects'] ?? 'N/A',
                    Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 16),
                  // Reviews
                  _buildReviewSection(medicine),
                  const SizedBox(height: 20),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
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

  Widget _buildReviewSection(Map<String, dynamic> medicine) {
    final excellent = medicine['Excellent Review %'] ?? 0;
    final average = medicine['Average Review %'] ?? 0;
    final poor = medicine['Poor Review %'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_rate, size: 20, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReviewBar('Excellent', excellent, Colors.green),
        const SizedBox(height: 8),
        _buildReviewBar('Average', average, Colors.orange),
        const SizedBox(height: 8),
        _buildReviewBar('Poor', poor, Colors.red),
      ],
    );
  }

  Widget _buildReviewBar(String label, dynamic percentage, Color color) {
    final percent = percentage is int ? percentage : int.tryParse(percentage.toString()) ?? 0;
    
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
