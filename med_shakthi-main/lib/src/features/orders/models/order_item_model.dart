class OrderItem {
  final String id;
  final String title;
  final String brand;
  final String size;
  final double price;
  final String imagePath;
  final int quantity;
  final String status;
  final String orderDate;
  final String deliveryLocation;
  final String paymentMode;

  OrderItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.size,
    required this.price,
    required this.imagePath,
    required this.quantity,
    required this.status,
    required this.orderDate,
    required this.deliveryLocation,
    required this.paymentMode,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      title: map['item_name'] ?? '',
      brand: map['brand'] ?? '',
      size: map['unit_size'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imagePath: map['image_url'] ?? '',
      quantity: map['quantity'] ?? 1,
      status: map['status'] ?? 'pending',
      orderDate: map['created_at']?.toString() ?? '',
      deliveryLocation: "Not Available",
      paymentMode: map['payment_status'] ?? 'pending',
    );
  }
}
