import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';

/// Singleton instance of WishlistService to be shared across the app
class WishlistServiceSingleton {
  static final WishlistService instance = WishlistService(userId: 'demo-user');
}
