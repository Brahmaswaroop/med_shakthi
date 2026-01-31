import 'package:flutter/material.dart';
import 'package:med_shakthi/src/features/dashboard/pharmacy_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4F2), Color(0xFFF6FBFA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF6AA39B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Logo
                  Center(
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _label('Full Name'),
                  _textField(
                    controller: _nameController,
                    hint: 'John Doe',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your name'
                        : null,
                  ),

                  const SizedBox(height: 20),

                  _label('Email'),
                  _textField(
                    controller: _emailController,
                    hint: 'emailaddress@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Enter valid email',
                  ),

                  const SizedBox(height: 20),

                  _label('Phone Number'),
                  _textField(
                    controller: _phoneController,
                    hint: '+91 9876543210',
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter phone number'
                        : null,
                  ),

                  const SizedBox(height: 20),

                  _label('Password'),
                  _textField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF6AA39B),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) => value != null && value.length >= 6
                        ? null
                        : 'Minimum 6 characters',
                  ),

                  const SizedBox(height: 20),

                  /// Terms & Conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: const Color(0xFF6AA39B),
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions & Privacy Policy',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onSignupPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6AA39B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Login Redirect
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: const Color(0xFF6AA39B),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept terms & conditions'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // 🔐 Step 1: Supabase Auth Signup
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Signup failed. Try again.');
      }

      // 🧾 Step 2: Insert into users table
      await supabase.from('users').insert({
        'id': user.id, // MUST match auth.users.id
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // ✅ Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // ➡️ Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PharmacyHomeScreen()),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
