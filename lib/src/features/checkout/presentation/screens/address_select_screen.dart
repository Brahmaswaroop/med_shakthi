import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:med_shakthi/src/features/checkout/data/models/address_model.dart';
import 'address_store.dart';
import 'payment_method_screen.dart';

class AddressSelectScreen extends StatefulWidget {
  const AddressSelectScreen({super.key});

  @override
  State<AddressSelectScreen> createState() => _AddressSelectScreenState();
}

class _AddressSelectScreenState extends State<AddressSelectScreen> {
  GoogleMapController? mapController;
  LatLng selectedLatLng = const LatLng(28.6139, 77.2090);
  String addressText = "Locating...";
  final TextEditingController _searchController = TextEditingController();
  bool _isMoving = false; // For pin animation

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
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

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

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
        // Address will be fetched by onCameraIdle
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Address not found")));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);

    setState(() => selectedLatLng = latLng);
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
  }

  void _showAddAddressBottomSheet({AddressModel? addressToEdit}) {
    if (addressToEdit != null) {
      _searchController.text = addressToEdit.fullAddress;
      selectedLatLng = LatLng(addressToEdit.lat, addressToEdit.lng);
      addressText = addressToEdit.fullAddress;
    } else {
      _searchController.clear();
      _getCurrentLocation(); // Auto-locate on open
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Important for glass/overlay effect
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 1. Top Bar with Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Search area, street...",
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (val) {
                              _searchAddress(
                                val,
                              ).then((_) => setSheetState(() {}));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Map Area (Expanded)
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: selectedLatLng,
                            zoom: 17,
                          ),
                          onMapCreated: (controller) {
                            mapController = controller;
                            if (addressToEdit != null) {
                              controller.animateCamera(
                                CameraUpdate.newLatLng(selectedLatLng),
                              );
                            }
                          },
                          onCameraMove: (position) {
                            selectedLatLng = position.target;
                            if (!_isMoving) {
                              setSheetState(() => _isMoving = true);
                            }
                          },
                          onCameraIdle: () async {
                            setSheetState(() => _isMoving = false);
                            setSheetState(
                              () => addressText = "Fetching address...",
                            );
                            await _getAddress(selectedLatLng);
                            // Refresh sheet to show new addressText
                            setSheetState(() {});
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          gestureRecognizers:
                              <Factory<OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                        ),

                        // Center Pin
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 35,
                            ), // Pin tip at center
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              margin: EdgeInsets.only(
                                bottom: _isMoving ? 10 : 0,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 45,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),

                        // "Locate Me" Button
                        Positioned(
                          right: 16,
                          bottom: 20,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Theme.of(context).cardColor,
                            onPressed: () {
                              _getCurrentLocation().then(
                                (_) => setSheetState(() {}),
                              );
                            },
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Address Details Panel (Bottom Static)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Hug content
                      children: [
                        const Text(
                          "SELECT LOCATION",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.red,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isMoving ? "Locating..." : addressText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal, // Brand color
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (_isMoving) return; // Wait until steady
                            if (addressText == "Locating..." ||
                                addressText == "Address not found" ||
                                addressText == "Fetching address...") {
                              return;
                            }

                            final user =
                                Supabase.instance.client.auth.currentUser;
                            if (user == null) return;

                            final newAddress = AddressModel(
                              id:
                                  addressToEdit?.id ??
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              userId: user.id,
                              title: "Home",
                              fullAddress: addressText,
                              lat: selectedLatLng.latitude,
                              lng: selectedLatLng.longitude,
                              isSelected: addressToEdit?.isSelected ?? false,
                            );

                            if (addressToEdit != null) {
                              await context.read<AddressStore>().updateAddress(
                                newAddress,
                              );
                            } else {
                              await context.read<AddressStore>().addAddress(
                                newAddress,
                              );
                            }

                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text(
                            "CONFIRM LOCATION",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      appBar: AppBar(
        title: const Text("Delivery Address"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddAddressBottomSheet(),
            icon: const Icon(Icons.add),
            tooltip: "Add New Address",
          ),
        ],
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : store.addresses.isEmpty
          ? const Center(child: Text("No address saved yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.addresses.length,
              itemBuilder: (_, i) {
                final address = store.addresses[i];

                // Wrap item in Dismissible for delete functionality
                return Dismissible(
                  key: Key(address.id),
                  direction:
                      DismissDirection.startToEnd, // Swipe Right to Delete
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Address"),
                        content: const Text(
                          "Are you sure you want to delete this address?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    store.deleteAddress(address.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Address deleted successfully"),
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      store.selectAddressLocal(address.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                          // 1. Radio Button for Selection
                          Transform.scale(
                            scale: 1.2,
                            child: Radio<String>(
                              value: address.id,
                              groupValue: store.selectedAddress?.id,
                              activeColor: Colors.teal,
                              onChanged: (val) {
                                if (val != null) store.selectAddressLocal(val);
                              },
                            ),
                          ),

                          // 2. Address Details
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
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.fullAddress,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // 3. Edit (Pencil) Button
                          IconButton(
                            onPressed: () {
                              _showAddAddressBottomSheet(
                                addressToEdit: address,
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
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
          onPressed: () {
            // Proceed to Payment
            if (store.selectedAddress == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select an address")),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentMethodScreen()),
            );
          },
          child: const Text(
            "Proceed to Payment",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
