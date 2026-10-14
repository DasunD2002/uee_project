import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

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
      final response = await _apiService.post('/auth/login', body: {
        'email': email,
        'password': password,
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
        return 'Invalid response format';
      } else {
        final data = jsonDecode(response.body);
        return data['errorDescription'] ?? 'Login failed';
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
    await _googleSignIn.signOut();
  }
}
