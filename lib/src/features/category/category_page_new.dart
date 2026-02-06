import 'package:flutter/material.dart';
import 'category_products_page.dart';

class CategoryPageNew extends StatelessWidget {
  const CategoryPageNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fc),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Shop by Category',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: deviceCategories.length,
        itemBuilder: (context, index) {
          final item = deviceCategories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CategoryProductsPage(categoryName: item.title),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 36, color: item.color),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final IconData icon;
  final Color color;

  CategoryItem({required this.title, required this.icon, required this.color});
}

final List<CategoryItem> deviceCategories = [
  CategoryItem(
    title: 'Thermometer',
    icon: Icons.thermostat,
    color: Colors.orange,
  ),
  CategoryItem(title: 'Oximeter', icon: Icons.favorite, color: Colors.red),
  CategoryItem(
    title: 'Weighing Scale',
    icon: Icons.monitor_weight,
    color: Colors.purple,
  ),
  CategoryItem(
    title: 'Supplements',
    icon: Icons.medication,
    color: Colors.green,
  ),
  CategoryItem(
    title: 'Surgical',
    icon: Icons.medical_services,
    color: Colors.blue,
  ),
];
