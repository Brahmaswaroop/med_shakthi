import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/order_detail_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  List<OrderDetailModel> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final orderId = widget.orderData['id']; // UUID of the order
      if (orderId == null) return;

      final res = await supabase
          .from('order_details')
          .select()
          .eq('order_id', orderId);

      final data = List<Map<String, dynamic>>.from(res);
      setState(() {
        _items = data.map((e) => OrderDetailModel.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching details: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parent Order Data
    final orderGroupId = (widget.orderData['order_group_id'] ?? "N/A")
        .toString();
    final status = (widget.orderData['status'] ?? "Pending").toString();
    final totalAmount = (widget.orderData['total_amount'] ?? 0).toString();
    // Assuming delivery/payment info is on the parent order table or derived
    // If not, we might need to fetch it or display defaults.
    // For now using safe defaults or values from widget.orderData if they existed there.
    // The previous implementation used 'deliveryLocation' from OrderItem, assuming it was flat.
    // We will use placeholders if missing in parent.
    final deliveryLocation =
        widget.orderData['delivery_address'] ?? "Address info not available";
    final paymentMode = widget.orderData['payment_method'] ?? "Online";

    final Color themeColor = Theme.of(context).primaryColor;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Order #$orderGroupId',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Items List
                  const Text(
                    "Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._items.map((item) => _buildItemCard(item, themeColor)),

                  if (_items.isEmpty)
                    const Center(child: Text("No items found for this order.")),

                  const SizedBox(height: 24),

                  // 2. Track Order
                  const Text(
                    'Track Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildTrackOrderStrip(status),
                  const SizedBox(height: 24),

                  // 3. Delivery & Payment
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Delivery Location',
                          value: deliveryLocation,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Payment Mode',
                          value: paymentMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Subtotal (Calculated)',
                          '\$${_calculateSubtotal().toStringAsFixed(2)}',
                        ),
                        // _buildSummaryRow('Discount', '-\$0.00'),
                        // _buildSummaryRow('Delivery Cost', '\$5.00'),
                        const Divider(),
                        _buildSummaryRow(
                          'Total Amount',
                          '₹$totalAmount',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Actions
                  _buildActionButtons(context, themeColor),
                ],
              ),
            ),
    );
  }

  double _calculateSubtotal() {
    return _items.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  Widget _buildItemCard(OrderDetailModel item, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported),
                  )
                : const Icon(Icons.medication, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.brand,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  '${item.unitSize} x ${item.qty}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '₹${(item.price * item.qty).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: themeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color themeColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Chat logic
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice coming soon')),
              );
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackOrderStrip(String currentStatus) {
    final statuses = ['Pending', 'Confirmed', 'Shipped', 'Delivered'];
    // Map backend status to our list if strictly needed, or just case-insensitive match
    int currentIndex = statuses.indexWhere(
      (s) => s.toLowerCase() == currentStatus.toLowerCase(),
    );
    if (currentIndex == -1) currentIndex = 0; // Default to first

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(statuses.length * 2 - 1, (index) {
              if (index % 2 == 0) {
                final circleIndex = index ~/ 2;
                final isCompleted = circleIndex <= currentIndex;
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? _getStatusColor(statuses[circleIndex])
                        : Colors.grey.shade300,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                );
              } else {
                final lineIndex = (index - 1) ~/ 2;
                final isCompleted = lineIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 4,
                    color: isCompleted
                        ? _getStatusColor(statuses[lineIndex])
                        : Colors.grey.shade300,
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: statuses.map((status) {
              final index = statuses.indexOf(status);
              final isCurrent = index == currentIndex;
              return Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.black : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
