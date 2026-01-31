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
  final supplierIdController = TextEditingController(text: 'Loading...');
  final expiryController = TextEditingController();

  /// CATEGORY + SUBCATEGORY
  String category = 'Medicines';
  String subCategory = 'Tablets';

  final Map<String, List<String>> categoryMap = {
    'Medicines': [
      'Tablets',
      'Syrups',
      'Capsules',
      'Injections',
      'Pain Relief',
    ],
    'Supplements': [
      'Protein',
      'Vitamins',
      'Omega 3',
      'Weight Gain',
      'Immunity',
    ],
    'Personal care': [
      'Skin care',
      'Hair care',
      'Body care',
      'Cosmetics',
    ],
    'Baby care': [
      'Diapers',
      'Baby Food',
      'Baby Lotion',
      'Baby Soap',
    ],
    'Devices': [
      'BP Monitor',
      'Thermometer',
      'Glucometer',
      'Nebulizer',
    ],
  };

  File? imageFile;
  String? supplierCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSupplierCode();
  }

  Future<void> fetchSupplierCode() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('suppliers')
          .select('supplier_code')
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          supplierCode = data?['supplier_code'];
          supplierIdController.text = supplierCode ?? 'Unknown';
        });
      }
    } catch (e) {
      debugPrint('Error fetching supplier code: $e');
    }
  }

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
    try {
      await supabase.storage
          .from('product-images')
          .upload(fileName, imageFile!,
          fileOptions: const FileOptions(upsert: true));

      return supabase.storage.from('product-images').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await uploadImage();

      await supabase.from('products').insert({
        'name': nameController.text,
        'generic_name': genericController.text,
        'brand': brandController.text,
        'sku': skuController.text,
        'price': double.parse(priceController.text),
        'unit_size': unitSizeController.text,
        'expiry_date': expiryController.text,
        'category': category,
        'sub_category': subCategory,
        'supplier_code': supplierCode,
        'image_url': imageUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product Added Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Save product error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Add New Product',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
              Row(
                children: [
                  Expanded(child: _input("SKU", skuController)),
                  const SizedBox(width: 10),
                  Expanded(child: _input("Unit Size", unitSizeController)),
                ],
              ),
              _input("Price", priceController,
                  keyboard: TextInputType.number),
              _supplierIdField(),
              _expiryField(),
              _categoryDropdown(),
              _subCategoryDropdown(),
              const SizedBox(height: 20),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supplierIdField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: supplierIdController,
        readOnly: true,
        style: const TextStyle(color: Colors.grey),
        decoration: _inputDecoration("Supplier ID"),
      ),
    );
  }

  Widget _expiryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: expiryController,
        readOnly: true,
        onTap: pickExpiryDate,
        validator: (v) => v!.isEmpty ? 'Select expiry date' : null,
        decoration: _inputDecoration("Expiry Date")
            .copyWith(suffixIcon: const Icon(Icons.calendar_today)),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: category,
        decoration: _inputDecoration("Category"),
        items: categoryMap.keys
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          setState(() {
            category = v!;
            subCategory = categoryMap[category]!.first;
          });
        },
      ),
    );
  }

  Widget _subCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: subCategory,
        decoration: _inputDecoration("Sub Category"),
        items: categoryMap[category]!
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => subCategory = v!),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CA6A8),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _isLoading ? null : saveProduct,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Product',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: imageFile == null
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tap to add product image',
                style: TextStyle(color: Colors.grey)),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(imageFile!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => v!.isEmpty ? 'Required' : null,
        decoration: _inputDecoration(label),
      ),
    );
  }
}
