import 'package:flutter/material.dart';
import '../../data/wishlist_service.dart';

class WishlistPage extends StatelessWidget {
  final WishlistService wishlistService;

  const WishlistPage({super.key, required this.wishlistService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Wishlist"),
      ),
      body: StreamBuilder(
        stream: wishlistService.getWishlistStream(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text("No items in wishlist"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return ListTile(
                leading: Image.network(item.image, width: 40),
                title: Text(item.name),
                subtitle: Text("\$${item.price}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    wishlistService.removeFromWishlist(item.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
