import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'AddressModel.dart';
import 'AddressStore.dart';
import 'paymentMethodScreen.dart';

class AddressSelectScreen extends StatefulWidget {
  const AddressSelectScreen({super.key});

  @override
  State<AddressSelectScreen> createState() => _AddressSelectScreenState();
}

class _AddressSelectScreenState extends State<AddressSelectScreen> {
  GoogleMapController? mapController;
  LatLng selectedLatLng = const LatLng(28.6139, 77.2090);
  String addressText = "Tap on map to select address";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AddressStore>().fetchAddresses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddress(LatLng pos) async {
    try {
      final placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isEmpty) return;

      final p = placemarks.first;

      setState(() {
        addressText =
        "${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.postalCode ?? ''}";
      });
    } catch (e) {
      setState(() {
        addressText = "Address not found";
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        setState(() => selectedLatLng = latLng);

        await _getAddress(latLng);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address not found")),
      );
    }
  }

  void _showAddAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
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
                    onTap: (pos) async {
                      setState(() => selectedLatLng = pos);
                      await _getAddress(pos);
                    },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                      ),
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
                    children: [
                      Text(
                        addressText,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () async {
                          final user = Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("User not logged in")),
                            );
                            return;
                          }

                          if (addressText == "Tap on map to select address" ||
                              addressText == "Address not found") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select valid address")),
                            );
                            return;
                          }

                          final address = AddressModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: user.id,
                            title: "Home",
                            fullAddress: addressText,
                            lat: selectedLatLng.latitude,
                            lng: selectedLatLng.longitude,
                          );

                          await context.read<AddressStore>().addAddress(address);

                          if (!mounted) return;
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AddressStore>();

    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Address"), centerTitle: true),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : store.addresses.isEmpty
          ? const Center(child: Text("No address saved yet"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: store.addresses.length,
        itemBuilder: (_, i) {
          final address = store.addresses[i];

          return GestureDetector(
            onTap: () {
              store.selectAddressLocal(address.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentMethodScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: address.isSelected
                      ? Colors.teal
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: address.isSelected
                        ? Colors.teal
                        : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: address.isSelected
                                ? Colors.teal
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (address.isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Selected",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _showAddAddressBottomSheet,
          child: const Text(
            "Add New Address",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


