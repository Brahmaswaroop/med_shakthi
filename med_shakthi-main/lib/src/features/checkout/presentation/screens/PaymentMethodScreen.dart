import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_success_screen.dart';

// import '../../../cart/cart_data.dart';
import '../../../cart/data/cart_data.dart';
import '../../../cart/data/cart_item.dart';
// import '../../../models/cart_item.dart';
import 'package:uuid/uuid.dart';


class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final supabase = Supabase.instance.client;

  String selectedMethod = "MasterCard";
  bool _loading = false;

  Widget paymentTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selectedMethod == title ? Colors.teal : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Radio<String>(
            value: title,
            groupValue: selectedMethod,
            onChanged: (value) {
              setState(() {
                selectedMethod = value!;
              });
            },
            activeColor: Colors.teal,
          )
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartData>();
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      //  Order group id (same for all cart items)
      final orderGroupId = const Uuid().v4(); // string uuid

      //  Totals
      final subTotal = cart.subTotal;
      const shipping = 10;
      final total = subTotal + shipping;

      //  Full JSON order items (whole cart)
      final orderItemsJson = cart.items.map((CartItem item) {
        return {
          "product_id": item.id,
          "item_name": item.title ?? item.name,
          "brand": item.brand ?? "",
          "unit_size": item.size ?? "",
          "image_url": item.imagePath ?? item.imageUrl ?? "",
          "price": item.price,
          "quantity": item.quantity,
        };
      }).toList();

      //  Insert rows: 1 row per cart item
      final List<Map<String, dynamic>> rows = cart.items.map((CartItem item) {
        return {
          "user_id": user.id,

          // optional (if you have)
          "supplier_id": null,
          "supplier_code": null,

          //  group ID must be uuid (NOT NULL)
          "order_group_id": orderGroupId,

          //  required product data
          "product_id": item.id, // MUST be uuid string
          "item_name": item.title ?? item.name,
          "brand": item.brand,
          "unit_size": item.size,
          "image_url": item.imagePath ?? item.imageUrl,

          //  required order values
          "price": item.price,
          "quantity": item.quantity,
          "total_amount": total, // same total for whole order group

          //  status check constraint values
          "status": "pending",
          "payment_status": "pending",

          // optional
          "shipping": shipping,
          "order_items": orderItemsJson, // json column
        };
      }).toList();

      //  INSERT all at once
      await supabase.from("orders").insert(rows);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Order Placed Successfully")),
      );

      cart.clearCart();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Order failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartData>();

    const shipping = 10;
    final subTotal = cart.subTotal;
    final total = subTotal + shipping;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Payment Method",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              paymentTile("MasterCard", Icons.credit_card),
              paymentTile("PayPal", Icons.account_balance_wallet),
              paymentTile("Visa", Icons.credit_score),
              paymentTile("Apple Pay", Icons.apple),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.teal),
                  label: const Text(
                    "Add New Card",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Coupon Code / Voucher",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter your code here",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: const Text("Apply"),
                  ),
                ],
              ),

              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal"),
                  Text("₹${subTotal.toStringAsFixed(2)}"),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shipping & Tax"),
                  Text("₹$shipping"),
                ],
              ),

              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Next", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
