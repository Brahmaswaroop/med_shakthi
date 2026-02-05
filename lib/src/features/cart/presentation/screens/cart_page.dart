import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports from your snippet (Provider & Data)
// Corrected paths based on your previous file structure
import '../../../checkout/presentation/screens/address_select_screen.dart';
import '../../data/cart_data.dart';
import '../../data/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  final Color themeColor = const Color(0xFF4C8077);
  // Remove hardcoded backgroundColor, will use theme instead

  @override
  Widget build(BuildContext context) {
    // Listen to changes in CartData using Provider.of
    final cart = Provider.of<CartData>(context);
    final int shipping = cart.items.isNotEmpty ? 10 : 0;
    final double total = cart.subTotal + shipping;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: cart.items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Modern App Bar
                      SliverAppBar(
                        floating: true,
                        pinned: true,
                        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                        elevation: 0,
                        centerTitle: true,
                        title: Text(
                          "My Cart",
                          style: TextStyle(
                            color: Theme.of(context).appBarTheme.foregroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () =>
                                _showClearCartDialog(context, cart),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),

                      // Cart Items List with Animation
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _CartItemCard(
                              item: cart.items[index],
                              index: index,
                              cart: cart,
                              themeColor: themeColor,
                            );
                          }, childCount: cart.items.length),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Checkout Section
                _buildCheckoutSection(context, cart, shipping, total),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: themeColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you haven\'t added anything yet.',
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
              shadowColor: themeColor.withValues(alpha: 0.4),
            ),
            child: const Text(
              "Start Shopping",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartData cart,
    int shipping,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(context, "Sub Total", cart.subTotal),
          const SizedBox(height: 12),
          _buildSummaryRow(context, "Shipping & Tax", shipping),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: themeColor.withValues(alpha: 0.4),
              ),
              onPressed: () {
                _showCheckoutConfirmDialog(context, cart, shipping);
              },
              child: const Text(
                "Checkout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, num value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
        Text(
          "₹${value is int ? value.toString() : value.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartData cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Cart?"),
        content: const Text(
          "Are you sure you want to remove all items from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCheckoutConfirmDialog(
    BuildContext context,
    CartData cart,
    int shipping,
  ) {
    final int totalItems = cart.items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final double total = cart.subTotal + shipping;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Confirm Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are placing an order for $totalItems item(s).'),
              const SizedBox(height: 16),
              _buildSummaryRow(context, 'Total Payable', total),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressSelectScreen(),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;
  final CartData cart;
  final Color themeColor;

  const _CartItemCard({
    required this.item,
    required this.index,
    required this.cart,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered Entry Animation
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with gray background
            Hero(
              tag: item.id,
              child: Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[900] 
                      : Colors.grey[50], 
                  borderRadius: BorderRadius.circular(15),
                ),
                child: item.imagePath?.startsWith('http') ?? false
                    ? Image.network(item.imagePath!, fit: BoxFit.contain)
                    : Image.asset(
                        item.imagePath ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (c, o, s) =>
                            Icon(Icons.medication, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300]),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[900] 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildQtyBtn(context, Icons.remove, () {
                    if (item.quantity > 1) {
                      cart.decrement(index);
                    } else {
                      _showRemoveConfirmation(context, cart, index);
                    }
                  }, color: item.quantity == 1 ? Colors.red : null),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _buildQtyBtn(context, Icons.add, () => cart.increment(index)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(BuildContext context, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[800] 
              : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color ?? Theme.of(context).iconTheme.color?.withOpacity(0.7)),
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context, CartData cart, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove Item?"),
        content: const Text("Do you want to remove this item from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              cart.remove(index);
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
