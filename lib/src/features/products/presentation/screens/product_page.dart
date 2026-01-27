import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../cart/data/cart_data.dart';
import '../../../cart/data/cart_item.dart';
import '../../../cart/presentation/screens/cart_page.dart';
import '../../data/models/product_model.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';
import 'package:med_shakthi/src/features/wishlist/data/models/wishlist_item_model.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: SafeArea(
        child: Column(
          children: [
            // 🔧 FIX: pass product to TopBar
            _TopBar(product: product),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _ProductImageCard(imageUrl: product.image),
                    const SizedBox(height: 16),
                    _ProductInfoSection(product: product),
                    const SizedBox(height: 16),
                    const _SelectPharmacyCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(product: product),
    );
  }
}

/* ---------------- TOP BAR ---------------- */

class _TopBar extends StatefulWidget {
  final Product product;

  const _TopBar({required this.product});

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  // ✅ SHARED INSTANCE (FIX)
  static final WishlistService wishlistService = WishlistService(
    userId: 'demo-user',
  );

  @override
  Widget build(BuildContext context) {
    final bool isWishlisted = wishlistService.isInWishlist(widget.product.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
          ),
          const Spacer(),

          // ❤️ FIXED WISHLIST ICON
          InkWell(
            onTap: () async {
              if (isWishlisted) {
                await wishlistService.removeFromWishlist(widget.product.id);
              } else {
                await wishlistService.addToWishlist(
                  WishlistItem(
                    id: widget.product.id,
                    name: widget.product.name,
                    price: widget.product.price,
                    image: widget.product.image,
                  ),
                );
              }
              setState(() {});
            },
            child: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
            ),
          ),

          const SizedBox(width: 12),
          const Icon(Icons.share),
        ],
      ),
    );
  }
}

/* ---------------- IMAGE CARD ---------------- */

class _ProductImageCard extends StatelessWidget {
  final String imageUrl;

  const _ProductImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Image.network(
        imageUrl,
        height: 230,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.image_not_supported, size: 80),
      ),
    );
  }
}

/* ---------------- PRODUCT INFO ---------------- */

class _ProductInfoSection extends StatelessWidget {
  final Product product;

  const _ProductInfoSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(product.category, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text("${product.rating}"),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "\$${product.price}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/* ---------------- PHARMACY CARD ---------------- */

class _SelectPharmacyCard extends StatelessWidget {
  const _SelectPharmacyCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: const [
            Icon(Icons.local_pharmacy, size: 40, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Walgreens Pharmacy\nFree delivery • 12 min',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Text('\$18.99', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

/* ---------------- BOTTOM BAR ---------------- */

class _BottomBar extends StatelessWidget {
  final Product product;

  const _BottomBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<CartData>().addItem(
                CartItem(
                  id: product.id,
                  name: product.name,
                  title: product.name,
                  brand: product.category,
                  size: 'Standard',
                  price: product.price,
                  imagePath: product.image,
                  imageUrl: product.image,
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item added to cart')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B894),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              "Add to Cart  •  \$${product.price}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
