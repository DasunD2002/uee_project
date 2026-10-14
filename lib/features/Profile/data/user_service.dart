import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../../core/services/account_data_store.dart';
import '../../../core/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  static String? cachedPhotoUrl;
  static String? cachedUserId;

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final session = await AccountSession.current();
      if (session == null) return null;
      final response = await _apiService.get('/users/${session.userId}', sessionToken: session.token);
      if (!await session.isCurrent) return null;
      cachedUserId = session.userId;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data['data'];
        cachedPhotoUrl = profile['photoUrl'];
        return profile;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates, {AccountSession? expectedSession}) async {
    try {
      final session = expectedSession ?? await AccountSession.current();
      if (session == null || !await session.isCurrent) return false;
      final response = await _apiService.put(
        '/users/${session.userId}', sessionToken: session.token, body: updates,
      );
      return await session.isCurrent && response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }
}
