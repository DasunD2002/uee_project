import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../explorer/data/journey_store.dart';
import '../../explorer/data/field_notes_store.dart';
import '../../Profile/data/user_service.dart';
import '../../Profile/domain/social_store.dart';
import '../../capsules/data/capsule_store.dart';
import '../../translations/data/translation_library_store.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];

        final userId = data['data']['id'];
        if (token is String &&
            token.isNotEmpty &&
            userId is String &&
            userId.isNotEmpty) {
          _clearAccountCaches();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          UserService.cachedUserId = userId;
          await prefs.setString('user_id', userId);
          return null; // Success
        }
        return 'Invalid response format';
      } else {
        final data = jsonDecode(response.body);
        return data['errorDescription'] ?? 'Login failed';
      }
    } catch (e) {
      debugPrint('Network error in login: $e');
      return 'Network error: $e';
    }
  }

  Future<String?> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/auth/register', body: userData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['errorDescription'] ?? 'Registration failed';
      }
    } catch (e) {
      return 'Network error occurred';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    _clearAccountCaches();
  }

  static void _clearAccountCaches() {
    JourneyStore.instance.reset();
    FieldNotesStore.instance.reset();
    SocialStore.instance.reset();
    CapsuleStore.instance.reset();
    TranslationLibraryStore.instance.reset();
    UserService.cachedUserId = null;
    UserService.cachedPhotoUrl = null;
  }
}
