import 'dart:convert';

class SupplierModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String pincode;
  final String companyName;
  final String companyType;
  final String companyAddress;
  final String drugLicenseNumber;
  final DateTime drugLicenseExpiry;
  final String drugLicenseDocument;
  final String gstNumber;
  final String panNumber;
  final String verificationStatus;
  final DateTime? createdAt;

  SupplierModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.pincode,
    required this.companyName,
    required this.companyType,
    required this.companyAddress,
    required this.drugLicenseNumber,
    required this.drugLicenseExpiry,
    required this.drugLicenseDocument,
    required this.gstNumber,
    required this.panNumber,
    this.verificationStatus = 'PENDING',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'state': state,
      'city': city,
      'pincode': pincode,
      'company_name': companyName,
      'company_type': companyType,
      'company_address': companyAddress,
      'drug_license_number': drugLicenseNumber,
      'drug_license_expiry': drugLicenseExpiry.toIso8601String(),
      'drug_license_document': drugLicenseDocument,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'verification_status': verificationStatus,
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      country: map['country'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      companyName: map['company_name'] ?? '',
      companyType: map['company_type'] ?? '',
      companyAddress: map['company_address'] ?? '',
      drugLicenseNumber: map['drug_license_number'] ?? '',
      drugLicenseExpiry: DateTime.parse(map['drug_license_expiry']),
      drugLicenseDocument: map['drug_license_document'] ?? '',
      gstNumber: map['gst_number'] ?? '',
      panNumber: map['pan_number'] ?? '',
      verificationStatus: map['verification_status'] ?? 'PENDING',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SupplierModel.fromJson(String source) =>
      SupplierModel.fromMap(json.decode(source));
}
