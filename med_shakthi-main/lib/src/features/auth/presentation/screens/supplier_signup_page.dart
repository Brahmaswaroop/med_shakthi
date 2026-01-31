import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:med_shakthi/src/core/api/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Assuming SupplierDashboard is located here based on your project structure
import 'package:med_shakthi/src/features/dashboard/supplier_dashboard.dart';

class SupplierSignupPage extends StatefulWidget {
  const SupplierSignupPage({super.key});

  @override
  State<SupplierSignupPage> createState() => _SupplierSignupPageState();
}

class _SupplierSignupPageState extends State<SupplierSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final SupabaseClient supabase = Supabase.instance.client;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _drugLicenseNumberController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCompanyType;
  DateTime? _selectedExpiryDate;
  File? _selectedDocument;
  String? _documentPath;

  final List<String> _companyTypes = [
    'PROPRIETORSHIP',
    'LLP',
    'PVT_LTD',
    'PARTNERSHIP',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _drugLicenseNumberController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _documentPath = result.files.single.name;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // ... (Validation checks remain the same) ...
    if (_selectedCompanyType == null) {
      _showError('Please select company type');
      return;
    }
    if (_selectedExpiryDate == null) {
      _showError('Please select drug license expiry date');
      return;
    }
    if (_selectedDocument == null) {
      _showError('Please upload drug license document');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔐 STEP 1: AUTH SIGNUP
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = authResponse.user;
      if (user == null) throw Exception('Auth signup failed');
      final userId = user.id;

      // 📂 STEP 2: UPLOAD DOCUMENT
      final fileName =
          'drug_license_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final documentUrl = await SupabaseService.uploadDocument(
        bucket: 'drug-licenses',
        file: _selectedDocument!,
        fileName: fileName,
      );

      // 🧾 STEP 3: INSERT INTO SUPPLIERS TABLE
      await supabase.from('suppliers').insert({
        'user_id': userId,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),

        // ✅ ADDED THIS BACK to satisfy the "NOT NULL" database constraint
        'password': _passwordController.text.trim(),

        'phone': _phoneController.text.trim(),
        'country': _countryController.text.trim(),
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'company_name': _companyNameController.text.trim(),
        'company_type': _selectedCompanyType,
        'company_address': _companyAddressController.text.trim(),
        'drug_license_number': _drugLicenseNumberController.text.trim(),
        'drug_license_expiry': _selectedExpiryDate!.toIso8601String(),
        'drug_license_document': documentUrl,
        'gst_number': _gstNumberController.text.trim(),
        'pan_number': _panNumberController.text.trim(),
        'verification_status': 'PENDING',
      });

      // ✅ SUCCESS UI & NAVIGATION
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Submitted! Welcome.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Supplier Dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SupplierDashboard()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4F2), Color(0xFFF6FBFA)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF6AA39B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Supplier Registration',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Join our network and grow your business',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 30),

                        _sectionTitle('Basic Info'),
                        _buildTextField(
                          _nameController,
                          'Contact Person Name',
                          Icons.person,
                        ),
                        _buildTextField(
                          _emailController,
                          'Email Address',
                          Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          _phoneController,
                          'Phone Number',
                          Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          _passwordController,
                          'Password',
                          Icons.lock,
                          keyboardType: TextInputType.visiblePassword,
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle('Location'),
                        _buildTextField(
                          _countryController,
                          'Country',
                          Icons.public,
                        ),
                        _buildTextField(_stateController, 'State', Icons.map),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _cityController,
                                'City',
                                Icons.location_city,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildTextField(
                                _pincodeController,
                                'Pincode',
                                Icons.pin_drop,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle('Business Details'),
                        _buildTextField(
                          _companyNameController,
                          'Company Name',
                          Icons.business,
                        ),
                        _buildDropdown(),
                        _buildTextField(
                          _companyAddressController,
                          'Full Business Address',
                          Icons.home_work,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle('Legal & Documents'),
                        _buildTextField(
                          _drugLicenseNumberController,
                          'Drug License Number',
                          Icons.description,
                        ),
                        _buildDatePicker(),
                        const SizedBox(height: 10),
                        _buildFilePicker(),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _gstNumberController,
                          'GST Number',
                          Icons.receipt_long,
                        ),
                        _buildTextField(
                          _panNumberController,
                          'PAN Number',
                          Icons.credit_card,
                        ),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6AA39B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Submit for Verification',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6AA39B),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCompanyType,
        decoration: InputDecoration(
          labelText: 'Company Type',
          prefixIcon: const Icon(Icons.category, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        items: _companyTypes.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        onChanged: (value) => setState(() => _selectedCompanyType = value),
        validator: (value) =>
            value == null ? 'Please select company type' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              _selectedExpiryDate == null
                  ? 'Drug License Expiry Date'
                  : 'Expiry: ${DateFormat('dd MMM yyyy').format(_selectedExpiryDate!)}',
              style: TextStyle(
                color: _selectedExpiryDate == null
                    ? Colors.grey[700]
                    : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6AA39B).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6AA39B).withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: const Color(0xFF6AA39B),
            ),
            const SizedBox(height: 10),
            Text(
              _documentPath ?? 'Upload Drug License Document',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6AA39B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '(PDF, JPG, PNG up to 5MB)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
