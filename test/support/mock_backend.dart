import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uee_project/core/services/api_service.dart';

Map<String, dynamic> testProfile = {};

void installMockBackend() {
  testProfile = {
    'id': 'test-user',
    'name': 'Amaya Wickrama',
    'handle': '@amaya.heritage',
    'bio': 'Test profile',
    'district': 'Kandy',
    'followerCount': 0,
    'followingCount': 0,
  };
  ApiService.testResponder = (method, endpoint, body) async {
    if (endpoint.endsWith('/follow')) {
      return http.Response(jsonEncode({'data': {
        'following': body?['following'] ?? false,
        'followerCount': body?['following'] == true ? 1 : 0, 'followingCount': 0,
      }}), 200);
    }
    if (endpoint.startsWith('/users/')) {
      final prefs = await SharedPreferences.getInstance();
      if (method == 'PUT') testProfile.addAll(body ?? {});
      final avatar = prefs.getString('profile.avatar');
      final cover = prefs.getString('profile.cover');
      return http.Response(
        jsonEncode({
          'data': {
            ...testProfile,
            if (avatar != null) 'photoUrl': 'data:image/png;base64,$avatar',
            if (cover != null) 'coverUrl': 'data:image/png;base64,$cover',
          },
        }),
        200,
      );
    }
    return http.Response('{"data":[]}', method == 'POST' ? 201 : 200);
  };
}
