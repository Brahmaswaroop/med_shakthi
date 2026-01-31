class CartItem {
  final String id;
  final String name; // Keeping 'name' for backward compatibility
  final String? title; // Made nullable
  final String? brand; // Made nullable
  final String? size; // Made nullable
  final double price;
  final String? imagePath; // Made nullable
  int quantity;
  String? imageUrl; // Kept for backward compatibility

  CartItem({
    required this.id,
    required this.name,
    this.title, // Optional
    this.brand, // Optional
    this.size, // Optional
    required this.price,
    this.imagePath, // Optional
    this.quantity = 1,
    this.imageUrl,
  });

  // Helper to get a display title (prefers title, falls back to name)
  String get displayTitle => title ?? name;

  // Helper to get a display image (prefers imagePath, falls back to imageUrl)
  String get displayImage => imagePath ?? imageUrl ?? '';

  // Get total price for this item
  double get totalPrice => price * quantity;

  // Convert CartItem to Map for local/remote storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'brand': brand,
      'size': size,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      // Removed serverTimestamp for JSON compatibility
    };
  }

  // Create CartItem from Map data
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      title: map['title'],
      brand: map['brand'],
      size: map['size'],
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imagePath: map['imagePath'],
      imageUrl: map['imageUrl'],
    );
  }

  // Copy method for updating quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      title: title,
      brand: brand,
      size: size,
      price: price,
      imagePath: imagePath,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }
}
