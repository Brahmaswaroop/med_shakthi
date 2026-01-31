import 'package:flutter/material.dart';
import '../widgets/category_chip.dart';
import '../widgets/medicine_card.dart';
import '../data/medicines_data.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String selectedCategory = "All";

  final categories = ["All", "Tablets", "Syrups", "Injections"];

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = selectedCategory == "All"
        ? medicines
        : medicines
        .where((m) => m["category"] == selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Medicines")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Categories
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryChip(
                    title: categories[index],
                    isSelected: selectedCategory == categories[index],
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Medicines list
            Expanded(
              child: ListView.builder(
                itemCount: filteredMedicines.length,
                itemBuilder: (context, index) {
                  final med = filteredMedicines[index];
                  return MedicineCard(
                    name: med["name"]!,
                    category: med["category"]!,
                    price: med["price"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
