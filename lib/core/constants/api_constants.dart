import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    // Fallback for local physical device testing using the machine's local IP
    return 'http://10.187.192.30:8080';
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
