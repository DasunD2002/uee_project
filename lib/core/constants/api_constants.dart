import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'host_ip.dart';

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

    String ip = hostIp;
    if (Platform.isAndroid && (ip == '127.0.0.1' || ip == 'localhost')) {
      ip = '10.0.2.2';
    }

    // Dynamic universal IP fetched at launch time via the pre-launch task
    return 'http://$ip:8080';
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
