import 'dart:async';
import '../../../core/services/account_data_store.dart';
import '../../../core/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../notifications/presentation/widgets/notification_item_tile.dart';

class SavedStory {
  const SavedStory({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
  });
  final String id, title, author, description;
}

class SavedCollection {
  SavedCollection({
    required this.name,
    this.image = 'ancient_cities',
    this.originalCount = 0,
  });
  final String name, image;
  final int originalCount;
  final Map<String, SavedStory> stories = {};
  int get count => originalCount + stories.length;
}

class SocialStore extends ChangeNotifier {
  SocialStore({this.document});
  final AccountDataStore? document;
  static final instance = SocialStore(
    document: isTestEnvironment ? null : AccountDataStore('social'),
  );
  bool _hydrated = false;
  int _generation = 0;
  String? get error => document?.error;

  Future<void> load() async {
    if (document == null || _hydrated) return;
    final generation = _generation;
    await document!.load();
    if (generation != _generation || !document!.loaded) return;
    final data = document!.data;
    if (data['collections'] is List) {
      collections
        ..clear()
        ..addAll(
          (data['collections'] as List).map((raw) {
            final item = raw as Map;
            final collection = SavedCollection(
              name: item['name'] as String,
              image: item['image'] as String? ?? 'ancient_cities',
            );
            for (final rawStory in item['stories'] as List? ?? []) {
              final story = rawStory as Map;
              collection.stories[story['id'] as String] = SavedStory(
                id: story['id'] as String,
                title: story['title'] as String,
                author: story['author'] as String,
                description: story['description'] as String,
              );
            }
            return collection;
          }),
        );
    }
    reports
      ..clear()
      ..addAll(Map<String, String>.from(data['reports'] as Map? ?? {}));
    notifications
      ..clear()
      ..addAll(
        (data['notifications'] as List? ?? []).map((raw) {
          final item = raw as Map;
          return NotificationItemData(
            id: item['id'] as String,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            timeAgo: item['timeAgo'] as String,
            avatarAsset: item['avatarAsset'] as String?,
            avatarUrl: item['avatarUrl'] as String?,
            icon: Icons.notifications_outlined,
            isUnread: item['isUnread'] as bool? ?? false,
          );
        }),
      );
    _hydrated = true;
    notifyListeners();
  }

  Map<String, dynamic> _snapshot() => {
    'collections': collections
        .map(
          (collection) => {
            'name': collection.name,
            'image': collection.image,
            'stories': collection.stories.values
                .map(
                  (story) => {
                    'id': story.id,
                    'title': story.title,
                    'author': story.author,
                    'description': story.description,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'reports': reports,
    'notifications': notifications
        .map(
          (item) => {
            'id': item.id,
            'title': item.title,
            'subtitle': item.subtitle,
            'timeAgo': item.timeAgo,
            'avatarAsset': item.avatarAsset,
            'avatarUrl': item.avatarUrl,
            'isUnread': item.isUnread,
          },
        )
        .toList(),
  };

  void _changed() {
    notifyListeners();
    if (document != null && _hydrated) {
      unawaited(
        document!.save(_snapshot()).catchError((Object _) {
          notifyListeners();
        }),
      );
    }
  }

  Future<void> flush() async {
    if (document == null) return;
    await load();
    await document!.save(_snapshot());
  }

  Future<void> report(String id, String reason) async {
    await load();
    reports[id] = reason;
    await flush();
  }

  void reset() {
    _generation++;
    _hydrated = false;
    for (final collection in collections) {
      collection.stories.clear();
    }
    collections.clear();
    reports.clear();
    comments.clear();
    likedPosts.clear();
    savedPosts.clear();
    notifications.clear();
    document?.reset();
    notifyListeners();
  }

  final collections = <SavedCollection>[
    SavedCollection(
      name: 'Hill Country Trails',
      image: 'hill_country',
      originalCount: 0,
    ),
    SavedCollection(name: 'Ancient Cities', originalCount: 0),
    SavedCollection(
      name: 'Craft & Makers',
      image: 'mask_carver',
      originalCount: 0,
    ),
    SavedCollection(
      name: 'Festival Season',
      image: 'festival',
      originalCount: 0,
    ),
    SavedCollection(
      name: 'Southern Coast',
      image: 'southern_coast',
      originalCount: 0,
    ),
    SavedCollection(
      name: 'Temple Rituals',
      image: 'temple_rituals',
      originalCount: 0,
    ),
  ];
  final Map<String, String> reports = {};
  final Map<String, List<String>> comments = {};
  final Set<String> likedPosts = {};
  final Set<String> savedPosts = {};
  bool isSaved(String id) => savedPosts.contains(id);
  SavedCollection addCollection(String name) {
    final existing = collections.where(
      (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first;
    final collection = SavedCollection(name: name.trim());
    collections.add(collection);
    _changed();
    return collection;
  }

  void saveTo(SavedStory story, Set<SavedCollection> selected) {
    for (final collection in collections) {
      if (selected.contains(collection)) {
        collection.stories[story.id] = story;
      } else {
        collection.stories.remove(story.id);
      }
    }
    _changed();
  }

  final List<NotificationItemData> notifications = [];

  int get unreadNotificationCount =>
      notifications.where((n) => n.isUnread).length;

  void addNotification(NotificationItemData n) {
    if (document != null && !_hydrated) {
      final generation = _generation;
      unawaited(
        load()
            .then((_) {
              if (generation == _generation && _hydrated) {
                notifications.insert(0, n);
                _changed();
              }
            })
            .catchError((Object _) {
              notifyListeners();
            }),
      );
      return;
    }
    notifications.insert(0, n);
    _changed();
  }

  void markAllNotificationsAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isUnread: false);
    }
    _changed();
  }

  void markNotificationAsRead(String id) {
    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i].id == id) {
        notifications[i] = notifications[i].copyWith(isUnread: false);
        _changed();
        break;
      }
    }
  }
}
