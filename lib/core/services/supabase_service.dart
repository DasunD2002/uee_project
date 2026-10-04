import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

class SupabaseService {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Uploads a file to Supabase Storage and returns its public URL.
  ///
  /// [file] is the local file to upload.
  /// [path] is the destination path within the bucket, e.g., 'images/profile.png'.
  Future<String?> uploadFile(File file, String path) async {
    try {
      final bucket = ApiConstants.supabaseBucketName;
      await _supabase.storage.from(bucket).upload(path, file);
      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading file to Supabase: $e');
      return null;
    }
  }

  Future<String?> uploadBytes(
    List<int> bytes,
    String path,
    String mimeType,
  ) async {
    try {
      final bucket = ApiConstants.supabaseBucketName;
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(contentType: mimeType),
          );
      return _supabase.storage.from(bucket).getPublicUrl(path);
    } on StorageException catch (e) {
      throw Exception('Supabase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  /// Optional: Remove a file from Supabase Storage
  Future<bool> deleteFile(String path) async {
    try {
      final bucket = ApiConstants.supabaseBucketName;
      await _supabase.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      debugPrint('Error deleting file from Supabase: $e');
      return false;
    }
  }
}
