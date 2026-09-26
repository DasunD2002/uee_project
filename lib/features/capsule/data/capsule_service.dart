import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../domain/capsule_model.dart';
import '../domain/capsule_memory.dart';

class CapsuleService {
  final ApiService _apiService = ApiService();
  static final List<CapsuleModel> _mockCapsules = [];

  static const String _storageKey = 'rootly_saved_capsules';

  static void clearMockCapsules() {
    _mockCapsules.clear();
  }

  static List<CapsuleMemory> defaultMemories() {
    return [
      CapsuleMemory(
        id: 'mem_1',
        type: MemoryType.photo,
        content: 'assets/images/login_image.jpg',
        title: 'Sigiriya trip',
        caption: 'Aachchi te ka',
        addedBy: 'Grandma',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CapsuleMemory(
        id: 'mem_2',
        type: MemoryType.photo,
        content: 'assets/images/gal_vihara.png',
        title: 'Polonnaruwa ruins',
        caption: 'The family table',
        addedBy: 'Uncle',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      CapsuleMemory(
        id: 'mem_3',
        type: MemoryType.photo,
        content: 'assets/images/mask_carver.png',
        title: 'Traditional artisan',
        caption: 'Her blessing',
        addedBy: 'You',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CapsuleMemory(
        id: 'mem_4',
        type: MemoryType.video,
        content: 'assets/images/gal_vihara.png',
        title: 'Watch Family Video',
        caption: 'Singing festive carols and blessing the house',
        addedBy: 'Uncle',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        durationSeconds: 45,
      ),
      CapsuleMemory(
        id: 'mem_5',
        type: MemoryType.letter,
        content:
            'May our family heritage forever guide your steps in truth and compassion. Keep this memory as a symbol of our eternal bond.',
        title: 'A letter for you',
        caption: 'Words from the heart',
        addedBy: 'Grandma',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<String> _resolveCreatorId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64.normalize(parts[1])));
          final data = jsonDecode(payload);
          final sub = data['sub']?.toString();
          if (sub != null && sub.isNotEmpty) return sub;
        }
      } catch (_) {}
    }
    return prefs.getString('user_email') ?? 'user';
  }

  Future<List<CapsuleModel>> _getLocalCapsules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        return list.map((e) => CapsuleModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveLocalCapsules(List<CapsuleModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(list.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (_) {}
  }

  /// 1. CREATE CAPSULE (POST /capsules)
  Future<String?> createCapsule(CapsuleModel capsule) async {
    if (isTestEnvironment) {
      _mockCapsules.add(capsule);
      return null;
    }
    try {
      final creatorId = await _resolveCreatorId();
      final response = await _apiService.post(
        '/capsules',
        body: capsule.toJson(defaultCreatorId: creatorId),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        CapsuleModel created = capsule.copyWith(
          memories: capsule.memories.isNotEmpty ? capsule.memories : defaultMemories(),
        );
        try {
          final data = jsonDecode(response.body);
          if (data['data'] is Map<String, dynamic>) {
            final fromBackend = CapsuleModel.fromJson(data['data']);
            created = fromBackend.copyWith(
              memories: defaultMemories(),
            );
          }
        } catch (_) {}

        final local = await _getLocalCapsules();
        local.insert(0, created);
        await _saveLocalCapsules(local);
        return null; // Success (no error)
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? data['message'] ?? 'Failed to create capsule';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }

  /// 2. UPDATE CAPSULE (PUT /capsules/{capsuleId})
  Future<String?> updateCapsule(String capsuleId, CapsuleModel capsule) async {
    if (isTestEnvironment) {
      final index = _mockCapsules.indexWhere((c) => c.id == capsuleId);
      if (index != -1) _mockCapsules[index] = capsule;
      return null;
    }
    try {
      final creatorId = await _resolveCreatorId();
      final response = await _apiService.put(
        '/capsules/$capsuleId',
        body: capsule.toJson(defaultCreatorId: creatorId),
      );

      final local = await _getLocalCapsules();
      final idx = local.indexWhere((c) => c.id == capsuleId || c.title == capsule.title);
      if (idx != -1) {
        local[idx] = capsule;
        await _saveLocalCapsules(local);
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success (no error)
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? data['message'] ?? 'Failed to update capsule';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }

  /// 3. DELETE CAPSULE (DELETE /capsules/{capsuleId})
  Future<String?> deleteCapsule(String capsuleId) async {
    if (isTestEnvironment) {
      _mockCapsules.removeWhere((c) => c.id == capsuleId);
      return null;
    }
    try {
      final response = await _apiService.delete('/capsules/$capsuleId');

      final local = await _getLocalCapsules();
      local.removeWhere((c) => c.id == capsuleId);
      await _saveLocalCapsules(local);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success (no error)
      }
      final data = jsonDecode(response.body);
      return data['errorDescription'] ?? data['message'] ?? 'Failed to delete capsule';
    } catch (e) {
      return 'Network error occurred: $e';
    }
  }

  /// 4. GET ALL CAPSULES (GET /capsules)
  Future<List<CapsuleModel>> getCapsules() async {
    if (isTestEnvironment) {
      return _mockCapsules.toList();
    }
    try {
      final local = await _getLocalCapsules();
      try {
        final response = await _apiService.get('/capsules');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final list = (data['data'] ?? data['content'] ?? data) as List?;
          if (list != null && list.isNotEmpty) {
            final remote = list.map((item) => CapsuleModel.fromJson(item)).toList();
            return remote;
          }
        }
      } catch (_) {}

      // If local capsules exist, ensure default memories exist
      if (local.isNotEmpty) {
        return local.map((c) {
          if (c.memories.isEmpty) {
            return c.copyWith(memories: defaultMemories());
          }
          return c;
        }).toList();
      }

      // Default initial sample capsule if none created yet
      return [
        CapsuleModel(
          id: 'default_family_recipe',
          title: 'Family Recipe',
          description: 'A collection of family recipes from grandmother to be shared.',
          category: 'Family',
          unlockDate: 'April 14, 2027',
          coverImageUrl: 'assets/images/login_image.jpg',
          memories: defaultMemories(),
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  /// 5. GET CAPSULE BY ID (GET /capsules/{capsuleId})
  Future<CapsuleModel?> getCapsuleById(String capsuleId) async {
    if (isTestEnvironment) {
      return _mockCapsules.firstWhere((c) => c.id == capsuleId);
    }
    try {
      final response = await _apiService.get('/capsules/$capsuleId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = jsonDecode(response.body);
        final capsuleData = data['data'] ?? data;
        return CapsuleModel.fromJson(capsuleData);
      }
    } catch (_) {}

    final local = await _getLocalCapsules();
    final match = local.where((c) => c.id == capsuleId).toList();
    return match.isNotEmpty ? match.first : null;
  }

  /// 6. ADD MEMORY TO CAPSULE
  Future<CapsuleModel?> addMemory(String capsuleId, CapsuleMemory memory) async {
    final local = await _getLocalCapsules();
    final idx = local.indexWhere((c) => c.id == capsuleId || (capsuleId.isEmpty && local.isNotEmpty));
    if (idx != -1) {
      final updatedMemories = List<CapsuleMemory>.from(local[idx].memories)..insert(0, memory);
      final updated = local[idx].copyWith(memories: updatedMemories);
      local[idx] = updated;
      await _saveLocalCapsules(local);
      return updated;
    }
    return null;
  }

  /// 7. DEV-ONLY TOGGLE UNLOCK SIMULATION
  Future<CapsuleModel?> toggleDebugUnlock(String capsuleId) async {
    if (!kDebugMode) return null;
    final local = await _getLocalCapsules();
    final idx = local.indexWhere((c) => c.id == capsuleId);
    if (idx != -1) {
      final updated = local[idx].copyWith(isDebugUnlocked: !local[idx].isDebugUnlocked);
      local[idx] = updated;
      await _saveLocalCapsules(local);
      return updated;
    }
    return null;
  }

  /// 8. ADD CONTRIBUTOR
  Future<CapsuleModel?> addContributor(String capsuleId, String name) async {
    final local = await _getLocalCapsules();
    final idx = local.indexWhere((c) => c.id == capsuleId);
    if (idx != -1) {
      final updatedContributors = List<String>.from(local[idx].contributors);
      if (!updatedContributors.contains(name)) {
        updatedContributors.add(name);
      }
      final updated = local[idx].copyWith(contributors: updatedContributors);
      local[idx] = updated;
      await _saveLocalCapsules(local);
      return updated;
    }
    return null;
  }
}
