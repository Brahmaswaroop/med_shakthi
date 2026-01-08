import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'AddressStore.dart';
import 'AddressModel/AddressModel.dart';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'address_store.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  GoogleMapController? mapController;
  LatLng selectedLatLng = const LatLng(28.6139, 77.2090);
  String addressText = "Tap on map to select address";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddress(LatLng pos) async {
    final placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final p = placemarks.first;

    setState(() {
      addressText =
          "${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}";
    });
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);
        setState(() {
          selectedLatLng = latLng;
        });
        await _getAddress(latLng);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      }
    } catch (e) {
      // Handle error, maybe show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Address"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for address",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _searchAddress,
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: selectedLatLng,
                zoom: 15,
              ),
              onMapCreated: (controller) => mapController = controller,
              onTap: (pos) {
                selectedLatLng = pos;
                _getAddress(pos);
              },
              markers: {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: selectedLatLng,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addressText,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () {
                    final address = AddressModel(
                      id: DateTime.now().toString(),
                      title: "Home",
                      fullAddress: addressText,
                      lat: selectedLatLng.latitude,
                      lng: selectedLatLng.longitude,
                    );

                    AddressStore.addAddress(address);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save Address",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// class AddAddressScreen extends StatefulWidget {
//   const AddAddressScreen({super.key});

//   @override
//   State<AddAddressScreen> createState() => _AddAddressScreenState();
// }

// class _AddAddressScreenState extends State<AddAddressScreen> {
//   GoogleMapController? mapController;
//   LatLng selectedLatLng = const LatLng(28.6139, 77.2090);
//   String addressText = "";

//   Future<void> getAddressFromLatLng(LatLng pos) async {
//     final placemarks = await placemarkFromCoordinates(
//       pos.latitude,
//       pos.longitude,
//     );
//     final place = placemarks.first;

//     setState(() {
//       addressText =
//           "${place.street}, ${place.locality}, ${place.administrativeArea}";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'New Address',
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: selectedLatLng,
//                 zoom: 15,
//               ),
//               onMapCreated: (c) => mapController = c,
//               onTap: (pos) {
//                 selectedLatLng = pos;
//                 getAddressFromLatLng(pos);
//               },
//               markers: {
//                 Marker(
//                   markerId: MarkerId("selected"),
//                   position: selectedLatLng,
//                 ),
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Text(
//                   addressText,
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 SizedBox(height: 12),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepOrange,
//                     minimumSize: const Size.fromHeight(52),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(
//                       context,
//                       AddressModel(
//                         id: DateTime.now().toString(),
//                         title: "My Home",
//                         fullAddress: addressText,
//                         lat: selectedLatLng.latitude,
//                         lng: selectedLatLng.longitude,
//                       ),
//                     );
//                   },
//                   child: Text("Save Address",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
