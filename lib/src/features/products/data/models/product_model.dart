class Product {
  final String id; //  uuid string
  final String name;
  final String category;
  final double price;
  final double rating;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.image,
  });

  // Supabase Map -> Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(), //  UUID safe
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
    );
  }

  // Alias for fromMap to support standard JSON decoding
  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

  //  Product -> Map (Insert/Update)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "category": category,
      "price": price,
      "rating": rating,
      "image": image,
    };
  }
}
