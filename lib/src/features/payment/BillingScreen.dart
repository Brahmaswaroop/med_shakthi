import 'package:flutter/material.dart';
import 'AddressStore.dart';
import 'AddressModel/AddressModel.dart';
import 'AddressSelectScreen.dart';
import 'PaymentMethodScreen.dart';
import 'AddAddressScreen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  Widget build(BuildContext context) {
    final address = AddressStore.selectedAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _openAddressSelectScreen,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: address == null
                    ? const Row(
                        children: [
                          Icon(Icons.add_location_alt, color: Colors.teal),
                          SizedBox(width: 12),
                          Text(
                            "Add Delivery Address",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text(
                                address.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            address.fullAddress,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openAddressSelectScreen,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Change Address",
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: address == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentMethodScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddressSelectScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressSelectScreen()),
    );
    setState(() {});
  }
}


// class BillingScreen extends StatefulWidget {
//   const BillingScreen({super.key});

//   @override
//   State<BillingScreen> createState() => _BillingScreenState();
// }

// class _BillingScreenState extends State<BillingScreen> {
//   AddressModel? selectedAddress;

//   @override
//   void initState() {
//     super.initState();

//     if (AddressStore.addresses.isEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _openAddressScreen();
//       });
//     } else {
//       selectedAddress = AddressStore.selectedAddress;
//     }
//   }

//   Future<void> _openAddressScreen() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddressSelectScreen()),
//     );

//     setState(() {
//       selectedAddress = AddressStore.selectedAddress;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Billing")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Delivery Address",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             GestureDetector(
//               onTap: _openAddressScreen,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: selectedAddress == null
//                     ? const Text("Add Address")
//                     : Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             selectedAddress!.title,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(selectedAddress!.fullAddress),
//                           const SizedBox(height: 6),
//                           const Text(
//                             "Change",
//                             style: TextStyle(color: Colors.teal),
//                           )
//                         ],
//                       ),
//               ),
//             ),

//             const Spacer(),

//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onPressed: selectedAddress == null
//                     ? null
//                     : () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => PaymentMethodScreen(),
//                           ),
//                         );
//                       },
//                 child: const Text("Next"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



// /////




// class PaymentMethodScreen extends StatefulWidget {
//   @override
//   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// }

// class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
//   String selectedMethod = "MasterCard";
//   AddressModel? selectedAddress;

//   @override
//   void initState() {
//     super.initState();

//     if (AddressStore.selectedAddress == null &&
//         AddressStore.addresses.isNotEmpty) {
//       selectedAddress = AddressStore.addresses.first;
//     } else {
//       selectedAddress = AddressStore.selectedAddress;
//     }

//     if (selectedAddress == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _openAddressSelector();
//       });
//     }
//   }

//   void _openAddressSelector() async {
//     final AddressModel? result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddressSelectScreen()),
//     );

//     if (result != null) {
//       setState(() {
//         selectedAddress = result;
//       });
//     }
//   }

//   Widget _addressSection() {
//     final address = selectedAddress ?? AddressStore.selectedAddress;

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Billing Address",
//               style: TextStyle(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           if (address != null)
//             Text(address.fullAddress,
//                 style: const TextStyle(color: Colors.black87)),
//           const SizedBox(height: 6),
//           TextButton(
//             onPressed: _openAddressSelector,
//             child: const Text("Change Address"),
//           )
//         ],
//       ),
//     );
//   }

//   Widget paymentTile(String title, IconData icon) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       trailing: Radio<String>(
//         value: title,
//         groupValue: selectedMethod,
//         onChanged: (v) => setState(() => selectedMethod = v!),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Checkout")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _addressSection(),
//             const SizedBox(height: 20),
//             paymentTile("MasterCard", Icons.credit_card),
//             paymentTile("PayPal", Icons.account_balance_wallet),
//             paymentTile("Visa", Icons.credit_score),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 minimumSize: const Size.fromHeight(55),
//               ),
//               child: const Text("Proceed to Pay"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }











