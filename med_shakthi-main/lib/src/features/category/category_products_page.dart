import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryProductsPage extends StatelessWidget {
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.categoryName,
  });

  // 🔹 SAFE CATEGORY MAPPING (UI → DB)
  static const Map<String, String> _categoryMap = {
    'Medicines': 'Medicine',
    'Supplements': 'Supplement',
    'Surgical': 'Surgical',
  };

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    // Convert UI category to DB category safely
    final dbCategory =
        _categoryMap[categoryName] ?? categoryName;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: supabase
            .from('products')
            .select()
            .eq('category', dbCategory) // ✅ FIXED HERE
            .not('supplier_id', 'is', null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data as List?;

          if (products == null || products.isEmpty) {
            return const Center(
              child: Text('No products available'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                title: Text(product['name'] ?? ''),
                subtitle: Text(product['category'] ?? ''),
                trailing: Text('₹${product['price']}'),
              );
            },
          );
        },
      ),
    );
  }
}
