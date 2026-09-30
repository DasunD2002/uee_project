import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();
  
  static String? cachedPhotoUrl;
  static String? cachedUserId;

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      cachedUserId = userId;
      if (userId == null) return null;

      final response = await _apiService.get('/users/$userId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data['data'];
        cachedPhotoUrl = profile['photoUrl'];
        return profile;
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return false;

      final response = await _apiService.put(
        '/users/$userId',
        body: updates,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
