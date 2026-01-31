class AddressModel {
  final String id;
  final String title;
  final String fullAddress;
  final double lat;
  final double lng;
  final bool isSelected;

  AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.lat,
    required this.lng,
    this.isSelected = false,
  });

  AddressModel copyWith({bool? isSelected}) {
    return AddressModel(
      id: id,
      title: title,
      fullAddress: fullAddress,
      lat: lat,
      lng: lng,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
