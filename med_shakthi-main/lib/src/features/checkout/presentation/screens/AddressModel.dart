class AddressModel {
  final String id;
  final String userId;
  final String title;
  final String fullAddress;
  final double lat;
  final double lng;
  final bool isSelected;

  AddressModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullAddress,
    required this.lat,
    required this.lng,
    this.isSelected = false,
  });

  AddressModel copyWith({bool? isSelected}) {
    return AddressModel(
      id: id,
      userId: userId,
      title: title,
      fullAddress: fullAddress,
      lat: lat,
      lng: lng,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: map['title'] ?? '',
      fullAddress: map['full_address'] ?? '',
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      isSelected: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'full_address': fullAddress,
      'lat': lat,
      'lng': lng,
    };
  }
}
