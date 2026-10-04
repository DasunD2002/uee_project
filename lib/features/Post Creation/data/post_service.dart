import '../../../core/services/account_data_store.dart';
import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../../Profile/domain/social_store.dart';
import 'package:flutter/material.dart';
import '../domain/user_post.dart';
import '../../notifications/presentation/widgets/notification_item_tile.dart';

class PostService {
  final ApiService _apiService = ApiService();
  static final List<UserPost> _mockPosts = [];

  static void clearMockPosts() {
    _mockPosts.clear();
  }

  Future<String?> createPost(
    UserPost post,
    String mediaUrl,
    List<String> proofUrls, {
    AccountSession? expectedSession,
  }) async {
    if (isTestEnvironment) {
      _mockPosts.add(post);
      return null;
    }
    try {
      final session = expectedSession ?? await AccountSession.current();
      if (session == null || !await session.isCurrent) return 'Your session changed. Please reopen the editor.';
      final response = await _apiService.post(
        '/posts', sessionToken: session.token,
        body: {
          'title': post.title,
          'story': post.story,
          'media': mediaUrl,
          'category': post.category,
          'location': '${post.place}, ${post.district}',
          'tags': post.tags,
          'visibility': post.isPrivate ? 'private' : 'public',
          'proofs': proofUrls,
          'disableComments': post.disableComments,
          'isDraft': post.isDraft,
        },
      );

      if (!await session.isCurrent) return 'Your account changed. Please reopen this screen.';
      if (response.statusCode == 201 || response.statusCode == 200) {
        SocialStore.instance.addNotification(
          NotificationItemData(
            id: DateTime.now().toString(),
            title: 'Post created',
            subtitle: post.isDraft ? 'Your draft was saved.' : 'Your post was successfully published.',
            timeAgo: 'Just now',
            icon: Icons.check_circle_outline,
            isUnread: true,
          ),
        );
        return null; // Success
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? 'Failed to create post';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }

  Future<String?> editPost(
    UserPost post,
    String mediaUrl,
    List<String> proofUrls, {
    AccountSession? expectedSession,
  }) async {
    if (isTestEnvironment) {
      final index = _mockPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) _mockPosts[index] = post;
      return null;
    }
    try {
      final session = expectedSession ?? await AccountSession.current();
      if (session == null || !await session.isCurrent) return 'Your session changed. Please reopen the editor.';
      final response = await _apiService.put(
        '/posts/${post.id}', sessionToken: session.token,
        body: {
          'title': post.title,
          'story': post.story,
          'media': mediaUrl,
          'category': post.category,
          'location': '${post.place}, ${post.district}',
          'tags': post.tags,
          'visibility': post.isPrivate ? 'private' : 'public',
          'proofs': proofUrls,
          'disableComments': post.disableComments,
          'isDraft': post.isDraft,
        },
      );

      if (!await session.isCurrent) return 'Your account changed. Please reopen this screen.';
      if (response.statusCode == 200) {
        SocialStore.instance.addNotification(
          NotificationItemData(
            id: DateTime.now().toString(),
            title: 'Post updated',
            subtitle: 'Your post was successfully updated.',
            timeAgo: 'Just now',
            icon: Icons.edit_outlined,
            isUnread: true,
          ),
        );
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
        SocialStore.instance.addNotification(
          NotificationItemData(
            id: DateTime.now().toString(),
            title: 'Post deleted',
            subtitle: 'Your post was removed from your profile.',
            timeAgo: 'Just now',
            icon: Icons.delete_outline,
            isUnread: true,
          ),
        );
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
        final posts = list.map((e) => UserPost.fromJson(e)).toList();
        for (final p in posts) {
          if (p.isLiked) {
            SocialStore.instance.likedPosts.add(p.id);
          } else {
            SocialStore.instance.likedPosts.remove(p.id);
          }
          final raw = list.firstWhere((item) => item['id'] == p.id);
          if (raw['isSaved'] == true) {
            SocialStore.instance.savedPosts.add(p.id);
          } else {
            SocialStore.instance.savedPosts.remove(p.id);
          }
        }
        return posts;
      }
      return [];
    } catch (e) {
      debugPrint('Network error fetching posts: $e');
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
        final posts = list.map((e) => UserPost.fromJson(e)).toList();
        for (final p in posts) {
          if (p.isLiked) {
            SocialStore.instance.likedPosts.add(p.id);
          } else {
            SocialStore.instance.likedPosts.remove(p.id);
          }
          final raw = list.firstWhere((item) => item['id'] == p.id);
          if (raw['isSaved'] == true) {
            SocialStore.instance.savedPosts.add(p.id);
          } else {
            SocialStore.instance.savedPosts.remove(p.id);
          }
        }
        return posts;
      }
      return [];
    } catch (e) {
      debugPrint('Network error fetching my posts: $e');
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
        final posts = list.map((e) => UserPost.fromJson(e)).toList();
        for (final p in posts) {
          if (p.isLiked) {
            SocialStore.instance.likedPosts.add(p.id);
          } else {
            SocialStore.instance.likedPosts.remove(p.id);
          }
          final raw = list.firstWhere((item) => item['id'] == p.id);
          if (raw['isSaved'] == true) {
            SocialStore.instance.savedPosts.add(p.id);
          } else {
            SocialStore.instance.savedPosts.remove(p.id);
          }
        }
        return posts;
      }
      return [];
    } catch (e) {
      debugPrint('Network error fetching saved posts: $e');
      return [];
    }
  }

  Future<void> _interaction(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _apiService.post(endpoint, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final data = jsonDecode(response.body);
      throw StateError(
        data['errorDescription'] ?? 'Could not save this action. Please retry.',
      );
    }
  }

  Future<void> likePost(String postId) => _interaction('/posts/$postId/like');
  Future<void> savePost(String postId) => _interaction('/posts/$postId/save');
  Future<void> commentPost(String postId, String text) =>
      _interaction('/posts/$postId/comment', body: {'text': text});
}
