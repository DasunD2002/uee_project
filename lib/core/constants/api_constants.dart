import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    // Android Emulator connects to host machine at 10.0.2.2:8080
    return 'http://10.0.2.2:8080';
  }

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://olapumiaskfkaqtsmynv.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_8dC2ToDUE-Xx92jsWQ2NCw_oRyCIkG7',
  );

  static const String supabaseBucketName = String.fromEnvironment(
    'SUPABASE_BUCKET',
    defaultValue: 'uploads',
  );
}
