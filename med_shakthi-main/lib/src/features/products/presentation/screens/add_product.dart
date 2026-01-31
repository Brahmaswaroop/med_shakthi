import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final genericController = TextEditingController();
  final brandController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final unitSizeController = TextEditingController();
  final supplierController = TextEditingController();
  final expiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill supplier_id if user is logged in
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      supplierController.text = currentUser.id;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    genericController.dispose();
    brandController.dispose();
    skuController.dispose();
    priceController.dispose();
    unitSizeController.dispose();
    supplierController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  String category = 'Medicine';
  File? imageFile;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<String?> uploadImage() async {
    if (imageFile == null) return null;

    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('product-images')
        .upload(
          fileName,
          imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('product-images').getPublicUrl(fileName);
  }

  bool _isLoading = false;

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // The table schema provided by the user:
      // id (uuid, auto), name (varchar), generic_name (varchar), brand (varchar),
      // sku (varchar), price (numeric), expiry_date (date), unit_size (varchar),
      // category (varchar), supplier_id (uuid), created_at (timestamptz, auto)

      final productData = {
        'name': nameController.text.trim(),
        'generic_name': genericController.text.trim(),
        'brand': brandController.text.trim(),
        'sku': skuController.text.trim(),
        'price': double.tryParse(priceController.text) ?? 0.0,
        'unit_size': unitSizeController.text.trim(),
        'expiry_date': expiryController.text.trim(),
        'category': category,
        'supplier_id': supplierController.text.trim().isNotEmpty
            ? supplierController.text.trim()
            : supabase.auth.currentUser?.id,
      };

      // Remove null values to let Supabase handle defaults/auto-gens
      productData.removeWhere((key, value) => value == null);

      await supabase.from('products').insert(productData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      expiryController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _imagePicker(),
              _input("Product Name", nameController),
              _input("Generic Name", genericController),
              _input("Brand", brandController),
              _input("SKU", skuController),
              _input("Price", priceController, keyboard: TextInputType.number),
              _input("Unit Size", unitSizeController),
              _input("Supplier ID", supplierController),
              _expiryField(),
              _categoryDropdown(),
              const SizedBox(height: 20),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // UI Components ↓↓↓

  Widget _imagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 140,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
        ),
        child: imageFile == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.black),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add product image',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(imageFile!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v!.isEmpty ? 'Required' : null,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _expiryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        controller: expiryController,
        readOnly: true,
        onTap: pickExpiryDate,
        validator: (v) => v!.isEmpty ? 'Select expiry date' : null,
        decoration: _inputDecoration(
          "Expiry Date",
        ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
      ),
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: category,
      style: const TextStyle(color: Colors.black),
      dropdownColor: Colors.white,
      items: const [
        DropdownMenuItem(
          value: 'Medicine',
          child: Text('Medicine', style: TextStyle(color: Colors.black)),
        ),
        DropdownMenuItem(
          value: 'Supplement',
          child: Text('Supplement', style: TextStyle(color: Colors.black)),
        ),
      ],
      onChanged: (v) => setState(() => category = v!),
      decoration: _inputDecoration("Category"),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8F87),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _isLoading ? null : saveProduct,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
