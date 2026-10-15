import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'host_ip.dart';

class ApiConstants {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String? _resolvedBaseUrl;

  static Future<void> init() async {
    if (_configuredBaseUrl.isNotEmpty) {
      _resolvedBaseUrl = _configuredBaseUrl;
      return;
    }

    if (kIsWeb) {
      _resolvedBaseUrl = 'http://localhost:8080';
      return;
    }

    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (!androidInfo.isPhysicalDevice) {
          // Android Emulator connects via 10.0.2.2
          _resolvedBaseUrl = 'http://10.0.2.2:8080';
        } else {
          // Physical Android device connects via USB reverse proxy (127.0.0.1:8080)
          _resolvedBaseUrl = 'http://127.0.0.1:8080';
        }
        return;
      } catch (_) {}
    }

    _resolvedBaseUrl = 'http://127.0.0.1:8080';
  }

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    if (_resolvedBaseUrl != null) {
      return _resolvedBaseUrl!;
    }

    String ip = hostIp;
    if (Platform.isAndroid && (ip == '127.0.0.1' || ip == 'localhost')) {
      ip = '10.0.2.2';
    }

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
