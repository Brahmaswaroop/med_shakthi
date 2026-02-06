import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_shakthi/src/features/profile/presentation/screens/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';
import 'package:med_shakthi/src/features/checkout/presentation/screens/address_store.dart';
import 'package:med_shakthi/src/features/checkout/presentation/screens/address_select_screen.dart';
import 'package:med_shakthi/src/features/cart/data/cart_data.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';
import '../../../orders/orders_page.dart';

import '../../../checkout/presentation/screens/payment_methods_for_pro_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  File? _profileImage;

  bool _isLoading = false;

  String _email = "Loading...";
  String _displayName = "User";
  String _phone = "";

  //  Address fields
  String _addressLine1 = "";
  String _addressLine2 = "";
  String _city = "";
  String _state = "";
  String _pincode = "";

  //  Orders list
  List<Map<String, dynamic>> _orders = [];
  bool _ordersLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchOrders();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final metaName =
          user.userMetadata?['name'] ?? user.userMetadata?['full_name'];

      setState(() {
        _email = user.email ?? "";
        _phone = user.phone ?? "";
        _displayName =
            metaName ?? (_email.isNotEmpty ? _email.split('@')[0] : "User");
      });

      //  Fetch from users table
      final data = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _displayName = data['name'] ?? _displayName;
          _phone = data['phone'] ?? _phone;

          _addressLine1 = data['address_line1'] ?? "";
          _addressLine2 = data['address_line2'] ?? "";
          _city = data['city'] ?? "";
          _state = data['state'] ?? "";
          _pincode = data['pincode'] ?? "";
        });
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _ordersLoading = true);

    try {
      final data = await supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint("Orders Error: $e");
    } finally {
      if (mounted) setState(() => _ordersLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      // Clear local persistence before signing out
      context.read<CartData>().clearLocalStateOnly();
      context.read<WishlistService>().clearWishlist();

      await supabase.auth.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _handleDeleteAccount() async {
    final passwordController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "This action cannot be undone. Please enter your password to confirm.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        // Re-authenticate user
        final user = supabase.auth.currentUser;
        if (user != null && user.email != null) {
          await supabase.auth.signInWithPassword(
            email: user.email!,
            password: passwordController.text,
          );

          // If sign-in succeeds, proceed to delete (using Edge Function or Admin API usually,
          // but calling rpc or just sign out if no delete mechanism exists yet in generic Supabase setup).
          // Assuming we want to call a function or just show success for now if strict delete isn't set up.
          // For now, attempting a standard user deletion pattern if RLS allows, or just signing out + visual confirmation.
          // Real deletion requires calling a Postgres function or Admin API.
          // We will mock the success flow and sign them out.
          await supabase.rpc(
            'delete_user',
          ); // Hypothetical RPC or just sign out
          await supabase.auth.signOut();

          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account deleted successfully")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressStore = context.watch<AddressStore>();
    // final selected = addressStore.selectedAddress; // Unused

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Account",
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  //  PROFILE CARD
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(48),
                          onTap: _pickProfileImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: const Color(
                                  0xFF6AA39B,
                                ).withValues(alpha: 0.12),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Text(
                                        _displayName.isNotEmpty
                                            ? _displayName[0].toUpperCase()
                                            : "U",
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              color: const Color(0xFF6AA39B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      )
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Color(0xFF6AA39B),
                                  child: Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                              if (_phone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _phone,
                                  style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  //  CONTENT
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 8),

                        //  Address Section (Navigates to AddressSelectScreen)
                        _SimpleExpansionTile(
                          title: 'Address',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressSelectScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        //  Orders Section (Navigates to OrdersPage)
                        _SimpleExpansionTile(
                          title: 'My Orders',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrdersPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        //  Payment Section (Static placeholder)
                        _SimpleExpansionTile(
                          title: "Payment Methods",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentMethodsPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        //  Settings Section
                        _SimpleExpansionTile(
                          title: 'Settings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text("Change Password"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                ),
                                onPressed: _handleDeleteAccount,
                                child: const Text("Delete Account"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        FilledButton(
                          onPressed: _handleLogout,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6AA39B),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text("Logout"),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddressBox() {
    final bool hasAddress =
        _addressLine1.isNotEmpty ||
        _addressLine2.isNotEmpty ||
        _city.isNotEmpty ||
        _state.isNotEmpty ||
        _pincode.isNotEmpty;

    if (!hasAddress) {
      return const Text("No address saved yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_addressLine1.isNotEmpty)
          Text(
            _addressLine1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        if (_addressLine2.isNotEmpty) Text(_addressLine2),
        const SizedBox(height: 6),
        Text(
          "${_city.isNotEmpty ? _city : ""}${_city.isNotEmpty && _state.isNotEmpty ? ", " : ""}${_state.isNotEmpty ? _state : ""}",
        ),
        if (_pincode.isNotEmpty) Text("Pincode: $_pincode"),
      ],
    );
  }

  Widget _buildOrdersBox() {
    if (_orders.isEmpty) {
      return const Text("No orders found.");
    }

    return Column(
      children: _orders.take(5).map((o) {
        final name = o['product_name'] ?? "Product";
        final price = o['price']?.toString() ?? "0";
        final status = o['status'] ?? "Pending";

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text("Status: $status"),
          trailing: Text(
            "₹$price",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }
}

class _SimpleExpansionTile extends StatelessWidget {
  const _SimpleExpansionTile({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
