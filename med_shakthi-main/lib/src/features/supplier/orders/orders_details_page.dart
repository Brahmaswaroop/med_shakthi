import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 📦 Order Summary
            _sectionTitle("Order Summary"),
            _infoRow("Order ID", orderId), // ✅ dynamic
            _infoRow("Order Date", "08 Jan 2026"),
            _infoRow("Status", "Pending"),
            _infoRow("Payment", "Credit (30 Days)"),
            const SizedBox(height: 20),

            // 🏥 Pharmacy Details
            _sectionTitle("Pharmacy Details"),
            _infoRow("Pharmacy Name", "ABC Medicals"),
            _infoRow("Contact", "+91 98765 43210"),
            _infoRow(
              "Delivery Address",
              "12, MG Road, Bengaluru, Karnataka",
            ),
            const SizedBox(height: 20),

            // 💊 Items Ordered
            _sectionTitle("Items Ordered"),
            _medicineItem(
              name: "Paracetamol 500mg",
              batch: "PCM5021",
              expiry: "Dec 2026",
              qty: "10 strips",
              price: "₹450",
            ),
            _medicineItem(
              name: "Amoxicillin 250mg",
              batch: "AMX1123",
              expiry: "Aug 2026",
              qty: "5 strips",
              price: "₹780",
            ),
            const SizedBox(height: 20),

            // 💰 Billing Summary
            _sectionTitle("Billing Summary"),
            _infoRow("Subtotal", "₹1,230"),
            _infoRow("GST (12%)", "₹147"),
            _infoRow("Total Amount", "₹1,377"),
            const SizedBox(height: 30),

            // 🚚 Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: Reject Order
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("Reject"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Accept / Dispatch Order
                  },
                  child: const Text("Accept Order"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineItem({
    required String name,
    required String batch,
    required String expiry,
    required String qty,
    required String price,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Batch: $batch"),
            Text("Expiry: $expiry"),
            Text("Quantity: $qty"),
            Text("Price: $price"),
          ],
        ),
      ),
    );
  }
}
