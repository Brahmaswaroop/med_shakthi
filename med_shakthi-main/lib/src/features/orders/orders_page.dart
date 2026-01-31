import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final supabase = Supabase.instance.client;

  String selectedStatus = "All";
  String searchText = "";

  bool _loading = false;
  List<Map<String, dynamic>> _orders = [];

  final List<String> statusList = [
    "All",
    "Pending",
    "Confirmed",
    "Shipped",
    "Delivered",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        _orders = [];
      });
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ Fetch user orders (latest first)
      final res = await supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> list =
      List<Map<String, dynamic>>.from(res);

      setState(() {
        _orders = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to fetch orders: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    List<Map<String, dynamic>> filtered = [..._orders];

    // ✅ Status filter
    if (selectedStatus != "All") {
      final statusDb = selectedStatus.toLowerCase();
      filtered = filtered.where((o) {
        final s = (o["status"] ?? "").toString().toLowerCase();
        return s == statusDb;
      }).toList();
    }

    // ✅ Search filter (order_group_id / item_name)
    if (searchText.trim().isNotEmpty) {
      final q = searchText.toLowerCase();
      filtered = filtered.where((o) {
        final orderId = (o["order_group_id"] ?? "").toString().toLowerCase();
        final itemName = (o["item_name"] ?? "").toString().toLowerCase();
        return orderId.contains(q) || itemName.contains(q);
      }).toList();
    }

    return filtered;
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return "";
    final dt = DateTime.tryParse(createdAt.toString());
    if (dt == null) return "";
    return "${dt.day.toString().padLeft(2, "0")}-${dt.month.toString().padLeft(2, "0")}-${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) {
                setState(() => searchText = v);
              },
              decoration: InputDecoration(
                hintText: "Search by Order ID or Item name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 🏷 Status Filters
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              itemBuilder: (context, index) {
                final status = statusList[index];
                final isSelected = selectedStatus == status;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedStatus = status);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ✅ Body
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? const Center(child: Text("No orders found."))
                : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _orderCard(orders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Order Card (Real data)
  Widget _orderCard(Map<String, dynamic> order) {
    final orderGroupId = (order["order_group_id"] ?? "").toString();
    final status = (order["status"] ?? "pending").toString();
    final itemName = (order["item_name"] ?? "Item").toString();
    final brand = (order["brand"] ?? "").toString();
    final qty = (order["quantity"] ?? 1).toString();
    final totalAmount = (order["total_amount"] ?? 0).toString();
    final date = _formatDate(order["created_at"]);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Order Group ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${orderGroupId.isEmpty ? "N/A" : orderGroupId.substring(0, 8)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 6),

            // ✅ Item / Brand
            Text(
              itemName,
              style: const TextStyle(fontSize: 14),
            ),
            if (brand.isNotEmpty)
              Text(
                brand,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

            const SizedBox(height: 6),

            // ✅ Amount + Qty
            Text("₹$totalAmount • Qty: $qty"),
            Text(
              "Ordered on: $date",
              style: const TextStyle(color: Colors.grey),
            ),

            const Divider(height: 20),

            // ✅ Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: order details page open
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Order: $orderGroupId")),
                    );
                  },
                  child: const Text("View Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Status Badge
  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    Color color;

    switch (s) {
      case "pending":
        color = Colors.orange;
        break;
      case "confirmed":
        color = Colors.blue;
        break;
      case "shipped":
        color = Colors.purple;
        break;
      case "delivered":
        color = Colors.green;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
