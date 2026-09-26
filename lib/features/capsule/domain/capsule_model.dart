import 'package:flutter/foundation.dart';
import 'capsule_memory.dart';

class CapsuleModel {
  final String? id;
  final String? creatorId;
  final String title;
  final String description;
  final String category;
  final String? type;
  final String? privacy;
  final String? unlockDate;
  final String? coverImageUrl;
  final bool? allowContributors;
  final DateTime? createdAt;
  final List<CapsuleMemory> memories;
  final List<String> contributors;
  final bool isDebugUnlocked;

  CapsuleModel({
    this.id,
    this.creatorId,
    required this.title,
    required this.description,
    this.category = 'Family',
    this.type,
    this.privacy = 'PRIVATE',
    this.unlockDate,
    this.coverImageUrl,
    this.allowContributors = true,
    this.createdAt,
    this.memories = const [],
    this.contributors = const ['Grandma', 'Uncle', 'You'],
    this.isDebugUnlocked = false,
  });

  // ── Capsule Lock Status Helpers (Single Source of Truth) ──────────────────

  /// Parses the unlock date string into a DateTime object
  DateTime? get parsedUnlockDate {
    if (unlockDate == null || unlockDate!.isEmpty) return null;
    final tryIso = DateTime.tryParse(unlockDate!);
    if (tryIso != null) return tryIso;

    // Handle formats like "April 14, 2027" or "June 10, 2027"
    try {
      final parts = unlockDate!.replaceAll(',', '').split(' ');
      if (parts.length >= 3) {
        final monthStr = parts[0].toLowerCase();
        final day = int.tryParse(parts[1]) ?? 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year + 1;
        final months = [
          'january', 'february', 'march', 'april', 'may', 'june',
          'july', 'august', 'september', 'october', 'november', 'december'
        ];
        final monthIndex = months.indexWhere((m) => m.startsWith(monthStr.substring(0, 3)));
        if (monthIndex != -1) {
          return DateTime(year, monthIndex + 1, day);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Formatted unlock date (e.g. "April 14, 2027")
  String get formattedUnlockDate {
    final parsed = parsedUnlockDate;
    if (parsed == null) return unlockDate ?? 'Future Date';
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  /// Whether the capsule is unlocked.
  /// If [checkDebug] is true and running in debug mode, [isDebugUnlocked] can force unlock.
  bool isUnlocked({bool checkDebug = true}) {
    if (checkDebug && kDebugMode && isDebugUnlocked) {
      return true;
    }
    final target = parsedUnlockDate;
    if (target == null) return false;
    return DateTime.now().isAfter(target);
  }

  /// Whether the capsule is still locked
  bool isLocked({bool checkDebug = true}) => !isUnlocked(checkDebug: checkDebug);

  /// Remaining time until unlock
  Duration get timeRemaining {
    final target = parsedUnlockDate;
    if (target == null) return Duration.zero;
    final diff = target.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Formatted live countdown string, e.g. "Opens in 364 days, 5 hrs"
  String get countdownString {
    if (isUnlocked()) {
      return 'Ready to open! ✦';
    }
    final rem = timeRemaining;
    if (rem.inDays > 0) {
      final hours = rem.inHours % 24;
      return 'Opens in ${rem.inDays} days${hours > 0 ? ', $hours hrs' : ''}';
    } else if (rem.inHours > 0) {
      final mins = rem.inMinutes % 60;
      return 'Opens in ${rem.inHours} hrs, $mins mins';
    } else if (rem.inMinutes > 0) {
      final secs = rem.inSeconds % 60;
      return 'Opens in ${rem.inMinutes} mins, $secs secs';
    } else {
      return 'Opens in ${rem.inSeconds} secs';
    }
  }

  Map<String, dynamic> toJson({String? defaultCreatorId}) {
    final effectiveType = (type != null && type!.isNotEmpty ? type! : category).toLowerCase();

    DateTime parsedDate;
    if (unlockDate != null && unlockDate!.isNotEmpty) {
      final parsed = DateTime.tryParse(unlockDate!);
      parsedDate = (parsed != null && parsed.isAfter(DateTime.now()))
          ? parsed
          : DateTime.now().add(const Duration(days: 365));
    } else {
      parsedDate = DateTime.now().add(const Duration(days: 365));
    }

    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'title': title,
      'description': description,
      'type': effectiveType,
      'creatorId': creatorId ?? defaultCreatorId ?? 'user',
      'privacy': privacy ?? 'PRIVATE',
      'unlockCondition': {
        'type': 'date',
        'date': parsedDate.toUtc().toIso8601String(),
      },
      if (coverImageUrl != null) 'coverPhotoUrl': coverImageUrl,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (allowContributors != null) 'allowContributors': allowContributors,
      'memories': memories.map((m) => m.toJson()).toList(),
      'contributors': contributors,
      if (kDebugMode) 'isDebugUnlocked': isDebugUnlocked,
    };
  }

  factory CapsuleModel.fromJson(Map<String, dynamic> json) {
    String? unlockDateStr;
    if (json['unlockCondition'] is Map) {
      unlockDateStr = json['unlockCondition']['date']?.toString();
    } else {
      unlockDateStr = json['unlockDate']?.toString();
    }

    List<CapsuleMemory> parsedMemories = [];
    if (json['memories'] is List) {
      parsedMemories = (json['memories'] as List)
          .map((item) => CapsuleMemory.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<String> parsedContributors = ['Grandma', 'Uncle', 'You'];
    if (json['contributors'] is List) {
      parsedContributors = (json['contributors'] as List).map((c) => c.toString()).toList();
    }

    return CapsuleModel(
      id: json['id'] ?? json['_id'],
      creatorId: json['creatorId']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? json['type'] ?? 'Family',
      type: json['type']?.toString(),
      privacy: json['privacy']?.toString() ?? 'PRIVATE',
      unlockDate: unlockDateStr,
      coverImageUrl: json['coverPhotoUrl'] ?? json['coverImageUrl'] ?? json['coverPhoto'],
      allowContributors: json['allowContributors'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      memories: parsedMemories,
      contributors: parsedContributors,
      isDebugUnlocked: json['isDebugUnlocked'] as bool? ?? false,
    );
  }

  CapsuleModel copyWith({
    String? id,
    String? creatorId,
    String? title,
    String? description,
    String? category,
    String? type,
    String? privacy,
    String? unlockDate,
    String? coverImageUrl,
    bool? allowContributors,
    DateTime? createdAt,
    List<CapsuleMemory>? memories,
    List<String>? contributors,
    bool? isDebugUnlocked,
  }) {
    return CapsuleModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      unlockDate: unlockDate ?? this.unlockDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      allowContributors: allowContributors ?? this.allowContributors,
      createdAt: createdAt ?? this.createdAt,
      memories: memories ?? this.memories,
      contributors: contributors ?? this.contributors,
      isDebugUnlocked: isDebugUnlocked ?? this.isDebugUnlocked,
    );
  }
}
