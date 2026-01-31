import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/wishlist_item_model.dart';

class WishlistService {
  final String userId;
  final SupabaseClient _supabase = Supabase.instance.client;

  WishlistService({required this.userId}) {
    _loadWishlist();
  }

  final List<WishlistItem> _wishlist = [];

  final StreamController<List<WishlistItem>> _wishlistController =
      StreamController<List<WishlistItem>>.broadcast();

  Stream<List<WishlistItem>> getWishlistStream() {
    Future.microtask(() {
      _wishlistController.add(List.unmodifiable(_wishlist));
    });
    return _wishlistController.stream;
  }

  void _emit() {
    _wishlistController.add(List.unmodifiable(_wishlist));
  }

  /// Load wishlist from Supabase on initialization
  Future<void> _loadWishlist() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('wishlist')
          .select('product_id, product_name, product_price, product_image')
          .eq('user_id', user.id);

      _wishlist.clear();
      for (var item in response) {
        _wishlist.add(WishlistItem(
          id: item['product_id'],
          name: item['product_name'],
          price: (item['product_price'] as num).toDouble(),
          image: item['product_image'],
        ));
      }
      _emit();
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  bool isInWishlist(String productId) {
    return _wishlist.any((item) => item.id == productId);
  }

  Future<void> addToWishlist(WishlistItem item) async {
    if (!isInWishlist(item.id)) {
      try {
        final user = _supabase.auth.currentUser;
        if (user == null) return;

        // Add to Supabase
        await _supabase.from('wishlist').insert({
          'user_id': user.id,
          'product_id': item.id,
          'product_name': item.name,
          'product_price': item.price,
          'product_image': item.image,
        });

        // Add to local list
        _wishlist.add(item);
        _emit();
      } catch (e) {
        print('Error adding to wishlist: $e');
      }
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Remove from Supabase
      await _supabase
          .from('wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', productId);

      // Remove from local list
      _wishlist.removeWhere((item) => item.id == productId);
      _emit();
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  Future<void> clearWishlist() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Clear from Supabase
      await _supabase.from('wishlist').delete().eq('user_id', user.id);

      // Clear local list
      _wishlist.clear();
      _emit();
    } catch (e) {
      print('Error clearing wishlist: $e');
    }
  }

  void dispose() {
    _wishlistController.close();
  }
}
