import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_item.dart';

class CartData extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = true;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get subTotal => _items.fold(0, (t, i) => t + i.price * i.quantity);

  CartData() {
    _init();
  }

  Future<void> _init() async {
    await _loadLocalCart();
    _isLoading = false;
    notifyListeners();
    // Fire and forget sync (don't block UI)
    _syncWithRemote();
  }

  // --- LOCAL STORAGE (SharedPreferences) ---

  Future<void> _loadLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString('local_cart');
      if (cartJson != null) {
        final List<dynamic> decodedList = jsonDecode(cartJson);
        _items = decodedList.map((e) => CartItem.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint("Error loading local cart: $e");
    }
  }

  Future<void> _saveLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cartJson = jsonEncode(_items.map((e) => e.toMap()).toList());
      await prefs.setString('local_cart', cartJson);
    } catch (e) {
      debugPrint("Error saving local cart: $e");
    }
  }

  // --- REMOTE SYNC (Supabase) ---

  Future<void> _syncWithRemote() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final supabase = Supabase.instance.client;

      // 1. Fetch remote items
      final List<dynamic> remoteData = await supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id);

      final List<CartItem> remoteItems = remoteData
          .map((e) => CartItem.fromMap(e))
          .toList();

      // 2. Merge Strategies
      // If remote has data, valid source of truth for now (or merge)
      // Let's do a simple merge: add local items to remote if missing, then update local to match remote.
      if (remoteItems.isNotEmpty) {
        _items = remoteItems; // Server wins
        _saveLocalCart();
        notifyListeners();
      } else if (_items.isNotEmpty) {
        // If remote empty but local has items -> Push to remote
        for (var item in _items) {
          await _addToRemote(item);
        }
      }
    } catch (e) {
      debugPrint("Error syncing cart: $e");
    }
  }

  Future<void> _addToRemote(CartItem item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Upsert
      await Supabase.instance.client.from('cart_items').upsert({
        'user_id': user.id,
        'id': item.id, // Keeping item ID same
        'product_id': item.id, // Assuming CartItem.id is product_id
        'quantity': item.quantity,
        'name': item.name,
        'price': item.price,
        'image': item.imagePath ?? item.imageUrl,
        // Add other fields if needed, or rely on product ID join
      });
    } catch (e) {
      debugPrint("Error adding to remote: $e");
    }
  }

  Future<void> _removeFromRemote(String itemId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client
          .from('cart_items')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', itemId); // Assuming id corresponds to product_id
    } catch (e) {
      debugPrint("Error removing from remote: $e");
    }
  }

  // --- PUBLIC METHODS ---

  Future<void> addItem(CartItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
    notifyListeners();
    _saveLocalCart();
    _addToRemote(index != -1 ? _items[index] : item);
  }

  Future<void> increment(int index) async {
    _items[index].quantity++;
    notifyListeners();
    _saveLocalCart();
    _addToRemote(_items[index]);
  }

  Future<void> decrement(int index) async {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
      _saveLocalCart();
      _addToRemote(_items[index]);
    }
  }

  Future<void> remove(int index) async {
    final item = _items[index];
    _items.removeAt(index);
    notifyListeners();
    _saveLocalCart();
    _removeFromRemote(item.id);
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    _saveLocalCart();
    // Optional: Clear remote too? Usually yes.
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('cart_items')
          .delete()
          .eq('user_id', user.id);
    }
  }
}
