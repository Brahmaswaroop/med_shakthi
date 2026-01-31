import 'dart:async';
import 'cart_item.dart';

class CartService {
  final String userId;
  final List<CartItem> _items = [];
  final StreamController<List<CartItem>> _cartController =
  StreamController<List<CartItem>>.broadcast();

  CartService({required this.userId}) {
    // Simulate real-time updates
    Timer.periodic(Duration(milliseconds: 100), (_) {
      _cartController.add(List.from(_items));
    });
  }

  Future<void> addToCart(CartItem item) async {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(item);
    }
  }

  Future<void> removeFromCart(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1 && quantity > 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
    } else if (quantity <= 0) {
      removeFromCart(itemId);
    }
  }

  Stream<List<CartItem>> getCartStream() => _cartController.stream;

  Stream<double> getCartTotalStream() {
    return getCartStream().map((items) =>
        items.fold(0.0, (sum, item) => sum + item.totalPrice));
  }

  Stream<int> getItemCountStream() {
    return getCartStream().map((items) => items.length);
  }

  Future<void> clearCart() async {
    _items.clear();
  }

  List<CartItem> getCart() => List.unmodifiable(_items);
}