import 'package:flutter/foundation.dart';

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
  bool isSaved(String id) => collections.any((c) => c.stories.containsKey(id));
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
}
