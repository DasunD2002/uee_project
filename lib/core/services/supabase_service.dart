import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a file to Supabase Storage and returns its public URL.
  /// 
  /// [file] is the local file to upload.
  /// [path] is the destination path within the bucket, e.g., 'images/profile.png'.
  Future<String?> uploadFile(File file, String path) async {
    try {
      final bucket = ApiConstants.supabaseBucketName;
      
      // Upload the file to the specified bucket
      await _supabase.storage.from(bucket).upload(path, file);

      // Get the public URL for the uploaded file
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading file to Supabase: $e');
      return null;
    }
  }

  /// Optional: Remove a file from Supabase Storage
  Future<bool> deleteFile(String path) async {
    try {
      final bucket = ApiConstants.supabaseBucketName;
      await _supabase.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting file from Supabase: $e');
      return false;
    }
  }
}
