import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/supplier_dashboard.dart';
import 'screens/login_page.dart';
import '../../dashboard/pharmacy_home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isSupplier = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // Check 'suppliers' table logic
      final data = await Supabase.instance.client
          .from('suppliers')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isSupplier = data != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4C8077))),
      );
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const LoginPage();
    }

    if (_isSupplier) {
      return const SupplierDashboard();
    } else {
      return const PharmacyHomeScreen();
    }
  }
}