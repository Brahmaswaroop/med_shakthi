import 'package:flutter/material.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Sales Analytics",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCards(),
            const SizedBox(height: 25),
            _sectionTitle("Sales Breakdown"),
            const SizedBox(height: 15),
            _salesBreakdown(),
            const SizedBox(height: 25),
            _sectionTitle("Top Selling Medicines"),
            const SizedBox(height: 15),
            _topProductsList(),
          ],
        ),
      ),
    );
  }

  // 🔢 Summary Cards
  Widget _summaryCards() {
    return Row(
      children: [
        _statCard("Today Sales", "₹ 82,450", "+12%"),
        const SizedBox(width: 15),
        _statCard("Monthly Sales", "₹ 18.6L", "+8%"),
      ],
    );
  }

  Widget _statCard(String title, String value, String growth) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              growth,
              style: const TextStyle(
                  color: Color(0xFF4CA6A8),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Sales Breakdown
  Widget _salesBreakdown() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _salesRow("Medicines", "₹ 9.8L"),
          _salesRow("Supplements", "₹ 5.2L"),
          _salesRow("OTC Products", "₹ 3.6L"),
        ],
      ),
    );
  }

  Widget _salesRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CA6A8))),
        ],
      ),
    );
  }

  // 💊 Top Products
  Widget _topProductsList() {
    return Column(
      children: [
        _productTile("Paracetamol 500mg", "1,240 units"),
        _productTile("Vitamin C Tablets", "980 units"),
        _productTile("Cough Syrup", "760 units"),
      ],
    );
  }

  Widget _productTile(String name, String qty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(qty,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D2D2D)),
    );
  }
}
