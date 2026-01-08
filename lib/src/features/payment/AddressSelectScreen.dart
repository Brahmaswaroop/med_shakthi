import 'package:flutter/material.dart';
import 'AddAddressScreen.dart';
import 'AddressStore.dart';

import 'package:flutter/material.dart';
import 'AddressStore.dart';
import 'AddressModel/addressModel.dart';

class AddressSelectScreen extends StatefulWidget {
  const AddressSelectScreen({super.key});

  @override
  State<AddressSelectScreen> createState() => _AddressSelectScreenState();
}

class _AddressSelectScreenState extends State<AddressSelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Address"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AddressStore.addresses.length,
        itemBuilder: (_, i) {
          final address = AddressStore.addresses[i];

          return GestureDetector(
            onTap: () {
              AddressStore.selectAddress(address.id);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      address.isSelected ? Colors.teal : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: address.isSelected
                    ? [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: address.isSelected ? Colors.teal : Colors.grey,
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
                            color:
                                address.isSelected ? Colors.teal : Colors.black,
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
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddAddressScreen()),
            );
            setState(() {});
          },
          child: const Text(
            "Add New Address",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// class AddressSelectScreen extends StatefulWidget {
//   const AddressSelectScreen({super.key});

//   @override
//   State<AddressSelectScreen> createState() => _AddressSelectScreenState();
// }

// class _AddressSelectScreenState extends State<AddressSelectScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Address")),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: AddressStore.addresses.length,
//         itemBuilder: (_, i) {
//           final address = AddressStore.addresses[i];
//           return GestureDetector(
//             onTap: () {
//               AddressStore.selectAddress(address.id);
//               Navigator.pop(context);
//             },
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: address.isSelected
//                       ? Colors.teal
//                       : Colors.grey.shade300,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(address.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 6),
//                   Text(address.fullAddress),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: () async {
//             final newAddress = await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const AddAddressScreen()),
//             );

//             if (newAddress != null) {
//               AddressStore.addAddress(newAddress);
//               setState(() {});
//             }
//           },
//           child: const Text("Add New Address"),
//         ),
//       ),
//     );
//   }
// }
