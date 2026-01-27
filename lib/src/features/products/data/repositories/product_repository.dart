
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all products (Real-time stream or simple future)
  Future<List<Product>> getProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false); // Newest first

      // --- DEBUG PRINT ---
      // This will show up in your "Run" tab. Check if it's empty [].
      print('📦 Supabase Raw Data: $response');

      // Convert the List<dynamic> from Supabase into List<Product>
      // We use the helper method from your product model (ensure it exists)
      return (response as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      // Return empty list on error (or handle it better in production)
      print('❌ Error fetching products: $e');
      return [];
    }
  }

  // --- NEW: Fetch products for a specific Supplier ---
  Future<List<Product>> getSupplierProducts(String supplierCode) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('supplier_code', supplierCode) // Filter by supplier
          .order('created_at', ascending: false);

      return (response as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching supplier products: $e');
      return [];
    }
  }

  // --- NEW: Delete a product ---
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      print('❌ Error deleting product: $e');
      rethrow;
    }
  }
}