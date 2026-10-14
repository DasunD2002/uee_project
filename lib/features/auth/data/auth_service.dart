import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
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

  // ─── IMPORTANT ──────────────────────────────────────────────────────────────
  // Replace the value below with your Android Client ID from Google Cloud Console
  // (APIs & Services > Credentials > OAuth 2.0 Client IDs > Android)
  // Android automatically identifies via google-services.json and its SHA-1 fingerprint.
  // Android Client ID: 818394054647-ukh2p8c02g33i3im3t5k4eltpo7eshg2.apps.googleusercontent.com

  // The serverClientId must match the Web Application Client ID configured
  // in google.client.id in the Spring Boot application.properties.
  static const String _webClientId =
      '818394054647-ru99mbpvdgnfg9i6pdiu36652fvo0rna.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // serverClientId tells the plugin to include a server auth code / ID token
    // that the backend can verify against the Web Client ID.
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['data']?['token'];
        final userId = data['data']?['id']?.toString() ?? '';
        if (token is String && token.isNotEmpty) {
          _clearAccountCaches();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          if (userId.isNotEmpty) {
            UserService.cachedUserId = userId;
            await prefs.setString('user_id', userId);
          }
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

  /// Triggers the native Google Sign-In flow, sends the ID token to the backend,
  /// and stores the returned JWT token. Returns null on success or an error string.
  Future<String?> loginWithGoogle({List<String>? languages}) async {
    try {
      // Trigger the Google Sign-In dialog
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google sign-in was cancelled';
      }

      // Obtain auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        return 'Failed to obtain Google ID token. '
            'Ensure the Web Client ID (serverClientId) is correctly set.';
      }

      // Send the ID token to the backend for verification
      final response = await _apiService.post('/auth/google', body: {
        'idToken': idToken,
        if (languages != null && languages.isNotEmpty) 'languages': languages,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          final userId = data['data']['id'];
          if (userId != null) {
            await prefs.setString('user_id', userId);
          }
          return null; // Success
        }
        return 'Invalid response from server';
      } else {
        final data = jsonDecode(response.body);
        return data['errorDescription'] ?? 'Google authentication failed';
      }
    } catch (e) {
      return 'Google sign-in error: $e';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    // Also sign out of Google so the account picker shows on the next attempt
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
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
