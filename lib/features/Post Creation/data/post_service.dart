import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';
import '../domain/user_post.dart';

class PostService {
  final ApiService _apiService = ApiService();
  static final List<UserPost> _mockPosts = [];

  static void clearMockPosts() {
    _mockPosts.clear();
  }

  static int mockPostsLength() => _mockPosts.length;
  static List<String> mockPostsTitles() => _mockPosts.map((p) => p.title).toList();

  Future<String?> createPost(UserPost post, String mediaUrl, List<String> proofUrls) async {
    if (isTestEnvironment) {
      _mockPosts.add(post);
      return null;
    }
    try {
      final response = await _apiService.post('/posts', body: {
        'title': post.title,
        'story': post.story,
        'media': mediaUrl,
        'category': post.category,
        'location': '${post.place}, ${post.district}',
        'tags': post.tags,
        'visibility': post.isPrivate ? 'private' : 'public',
        'proofs': proofUrls,
        'disableComments': post.disableComments,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? 'Failed to create post';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }

  Future<String?> editPost(UserPost post, String mediaUrl, List<String> proofUrls) async {
    if (isTestEnvironment) {
      final index = _mockPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) _mockPosts[index] = post;
      return null;
    }
    try {
      final response = await _apiService.put('/posts/${post.id}', body: {
        'title': post.title,
        'story': post.story,
        'media': mediaUrl,
        'category': post.category,
        'location': '${post.place}, ${post.district}',
        'tags': post.tags,
        'visibility': post.isPrivate ? 'private' : 'public',
        'proofs': proofUrls,
        'disableComments': post.disableComments,
      });

      if (response.statusCode == 200) {
        return null; // Success
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? 'Failed to edit post';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }

  Future<String?> deletePost(String postId) async {
    if (isTestEnvironment) {
      _mockPosts.removeWhere((p) => p.id == postId);
      return null;
    }
    try {
      final response = await _apiService.delete('/posts/$postId');
      if (response.statusCode == 200) {
        return null;
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? 'Failed to delete post';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }
  Future<List<UserPost>?> getAllPosts() async {
    if (isTestEnvironment) {
      return _mockPosts.toList();
    }
    try {
      final response = await _apiService.get('/posts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list == null) return [];
        return list.map((e) => UserPost.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Network error fetching posts: $e');
      return [];
    }
  }
  Future<List<UserPost>?> getMyPosts() async {
    if (isTestEnvironment) {
      return _mockPosts.toList();
    }
    try {
      final response = await _apiService.get('/posts/my');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list == null) return [];
        return list.map((e) => UserPost.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Network error fetching my posts: $e');
      return [];
    }
  }

  Future<List<UserPost>?> getSavedPosts() async {
    try {
      final response = await _apiService.get('/posts/saved');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List?;
        if (list == null) return [];
        return list.map((e) => UserPost.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Network error fetching saved posts: $e');
      return [];
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _apiService.post('/posts/$postId/like');
    } catch (e) {
      print('Network error liking post: $e');
    }
  }

  Future<void> commentPost(String postId, String text) async {
    try {
      await _apiService.post('/posts/$postId/comment', body: {'text': text});
    } catch (e) {
      print('Network error commenting on post: $e');
    }
  }
}
