import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<String> uploadDocument({
    required String bucket,
    required File file,
    required String fileName,
  }) async {
    final String path = await client.storage
        .from(bucket)
        .upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    return client.storage.from(bucket).getPublicUrl(fileName);
  }

  static Future<void> insertSupplier(Map<String, dynamic> supplierData) async {
    await client.from('suppliers').insert(supplierData);
  }
}
