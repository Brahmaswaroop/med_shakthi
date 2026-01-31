

import 'models/AddressModel.dart';

class AddressStore {
  static List<AddressModel> addresses = [
    AddressModel(
      id: '1',
      title: 'Home',
      fullAddress: '221B Baker Street, London',
      lat: 28.61,
      lng: 77.20,
      isSelected: true,
    ),
  ];

  static AddressModel? get selectedAddress =>
      addresses.firstWhere((a) => a.isSelected, orElse: () => addresses.first);

  static void selectAddress(String id) {
    addresses =
        addresses.map((a) => a.copyWith(isSelected: a.id == id)).toList();
  }

  static void addAddress(AddressModel address) {
    addresses = addresses.map((a) => a.copyWith(isSelected: false)).toList();
    addresses.add(address.copyWith(isSelected: true));
  }
}
