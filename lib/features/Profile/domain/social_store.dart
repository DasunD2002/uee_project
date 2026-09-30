import 'package:flutter/foundation.dart';
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
  static final instance = SocialStore();
  final collections = <SavedCollection>[
    SavedCollection(
      name: 'Hill Country Trails',
      image: 'hill_country',
      originalCount: 14,
    ),
    SavedCollection(name: 'Ancient Cities', originalCount: 23),
    SavedCollection(
      name: 'Craft & Makers',
      image: 'mask_carver',
      originalCount: 9,
    ),
    SavedCollection(
      name: 'Festival Season',
      image: 'festival',
      originalCount: 31,
    ),
    SavedCollection(
      name: 'Southern Coast',
      image: 'southern_coast',
      originalCount: 7,
    ),
    SavedCollection(
      name: 'Temple Rituals',
      image: 'temple_rituals',
      originalCount: 18,
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
    notifyListeners();
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
    notifyListeners();
  }

  final List<NotificationItemData> notifications = [
    const NotificationItemData(
      id: 'mock_like_1',
      title: 'Dinesh liked your post',
      subtitle: 'Your post received a new like.',
      timeAgo: '1m ago',
      icon: Icons.favorite,
      isUnread: true,
    ),
    const NotificationItemData(
      id: 'mock_follow_1',
      title: 'Amaya started following you',
      subtitle: 'You have a new follower!',
      timeAgo: '5m ago',
      icon: Icons.person_add,
      isUnread: true,
    ),
    const NotificationItemData(
      id: 'today_1',
      title: 'Kumari Devi added a photo to the Family Capsule',
      subtitle: 'New memory shared in "Sinhala New Year 2024"',
      timeAgo: '2h ago',
      avatarAsset: '',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
      isUnread: true,
    ),
    const NotificationItemData(
      id: 'today_2',
      title: 'System: Weekly Digest is ready',
      subtitle: "Review your family's archival activity from this past week.",
      timeAgo: '5h ago',
      icon: Icons.article_outlined,
      isUnread: false,
    ),
    const NotificationItemData(
      id: 'yesterday_1',
      title: "Saman Kumara left an audio note on Grandson's 18th Birthday",
      subtitle: '"Wishing you all the best on your journey ahead..."',
      timeAgo: 'Yesterday',
      avatarAsset: '',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      isUnread: false,
    ),
    const NotificationItemData(
      id: 'yesterday_2',
      title: 'Vault Update: Security Check Completed',
      subtitle:
          'Your digital heirlooms remain securely sealed and backed up.',
      timeAgo: 'Yesterday',
      icon: Icons.verified_user_outlined,
      isUnread: false,
    ),
  ];

  int get unreadNotificationCount => notifications.where((n) => n.isUnread).length;

  void addNotification(NotificationItemData n) {
    notifications.insert(0, n);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isUnread: false);
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i].id == id) {
        notifications[i] = notifications[i].copyWith(isUnread: false);
        notifyListeners();
        break;
      }
    }
  }
}
