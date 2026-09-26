import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

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
        final token = data['data']?['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          return null; // Success
        }
        return 'Invalid response format';
      } else {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['errorDescription'] != null) {
            return data['errorDescription'] as String;
          }
          if (data is Map && data['message'] != null) {
            return data['message'] as String;
          }
        } catch (_) {}

        if (response.statusCode == 401) {
          return 'Invalid email or password';
        }
        return 'Login failed (${response.statusCode})';
      }
    } catch (e) {
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
  }
}
