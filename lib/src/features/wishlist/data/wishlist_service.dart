import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/wishlist_item_model.dart';

class WishlistService extends ChangeNotifier {
  WishlistService({String? userId});

  final SupabaseClient _supabase = Supabase.instance.client;
  List<WishlistItem> _wishlist = [];

  List<WishlistItem> get wishlist => List.unmodifiable(_wishlist);

  bool isInWishlist(String productId) {
    return _wishlist.any((item) => item.id == productId);
  }

  /// Init: Load from Local Storage first, then Sync with Supabase
  Future<void> fetchWishlist() async {
    await _loadFromLocal(); // ⚡ Instant Load

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await _supabase
            .from('wishlist')
            .select()
            .eq('user_id', user.id);

        final List<dynamic> data = response as List<dynamic>;
        _wishlist = data.map((e) => WishlistItem.fromMap(e)).toList();
        notifyListeners();
        _saveToLocal(); // 💾 Sync Cloud -> Local
      } catch (e) {
        if (kDebugMode) print('Supabase fetch failed (using local): $e');
        // Fallback is already loaded from _loadFromLocal()
      }
    }
  }

  /// Add: Save Local + Supabase
  Future<void> addToWishlist(WishlistItem item) async {
    if (isInWishlist(item.id)) return;

    _wishlist.add(item);
    notifyListeners();
    _saveToLocal(); // 💾 Save Local

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('wishlist').upsert(item.toMap(user.id));
      } catch (e) {
        if (kDebugMode) print('Supabase add failed: $e');
      }
    }
  }

  /// Remove: Save Local + Supabase
  Future<void> removeFromWishlist(String productId) async {
    _wishlist.removeWhere((item) => item.id == productId);
    notifyListeners();
    _saveToLocal(); // 💾 Save Local

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('wishlist')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', productId);
      } catch (e) {
        if (kDebugMode) print('Supabase remove failed: $e');
      }
    }
  }

  /// 💾 Local Storage: Save
  Future<void> _saveToLocal() async {
    final user = _supabase.auth.currentUser;
    final String key = user != null ? 'wishlist_${user.id}' : 'local_wishlist';

    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = _wishlist.map((item) {
      return jsonEncode(item.toMap(user?.id ?? 'local_user'));
    }).toList();
    await prefs.setStringList(key, jsonList);
  }

  /// 💾 Local Storage: Load
  Future<void> _loadFromLocal() async {
    final user = _supabase.auth.currentUser;
    final String key = user != null ? 'wishlist_${user.id}' : 'local_wishlist';

    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(key);

    if (jsonList != null) {
      _wishlist = jsonList.map((jsonStr) {
        return WishlistItem.fromMap(jsonDecode(jsonStr));
      }).toList();
      notifyListeners();
    } else {
      _wishlist = [];
    }
  }

  Future<void> clearWishlist() async {
    _wishlist.clear();
    notifyListeners();
    // Do not clear 'local_wishlist' generic key, but clear specific user key if needed
    // Actually standard clearWishlist might be used for 'Clear All' feature?
    // If this is for LOGOUT, we should use clearLocalStateOnly.
    // For now, let's assume this clearWishlist IS the logout clear.
    final user = _supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.remove('wishlist_${user.id}');
    } else {
      await prefs.remove('local_wishlist');
    }
  }
}
