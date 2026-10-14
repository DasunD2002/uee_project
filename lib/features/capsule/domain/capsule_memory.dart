enum MemoryType {
  photo,
  video,
  letter,
  voice;

  String get displayName {
    switch (this) {
      case MemoryType.photo:
        return 'Photo';
      case MemoryType.video:
        return 'Video';
      case MemoryType.letter:
        return 'Letter';
      case MemoryType.voice:
        return 'Voice Note';
    }
  }

  static MemoryType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'video':
        return MemoryType.video;
      case 'letter':
        return MemoryType.letter;
      case 'voice':
        return MemoryType.voice;
      case 'photo':
      default:
        return MemoryType.photo;
    }
  }
}

class CapsuleMemory {
  final String id;
  final MemoryType type;
  final String content; // File path, image asset/network URL, or letter body
  final String? title; // Letter title or photo/video caption
  final String? caption;
  final String addedBy;
  final String? addedByAvatar;
  final DateTime createdAt;
  final int? durationSeconds; // For voice notes & videos

  CapsuleMemory({
    required this.id,
    required this.type,
    required this.content,
    this.title,
    this.caption,
    required this.addedBy,
    this.addedByAvatar,
    required this.createdAt,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      if (title != null) 'title': title,
      if (caption != null) 'caption': caption,
      'addedBy': addedBy,
      if (addedByAvatar != null) 'addedByAvatar': addedByAvatar,
      'createdAt': createdAt.toIso8601String(),
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
    };
  }

  factory CapsuleMemory.fromJson(Map<String, dynamic> json) {
    return CapsuleMemory(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MemoryType.fromString(json['type']),
      content: json['content'] ?? '',
      title: json['title'],
      caption: json['caption'],
      addedBy: json['addedBy'] ?? 'You',
      addedByAvatar: json['addedByAvatar'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      durationSeconds: json['durationSeconds'] as int?,
    );
  }

  CapsuleMemory copyWith({
    String? id,
    MemoryType? type,
    String? content,
    String? title,
    String? caption,
    String? addedBy,
    String? addedByAvatar,
    DateTime? createdAt,
    int? durationSeconds,
  }) {
    return CapsuleMemory(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      addedBy: addedBy ?? this.addedBy,
      addedByAvatar: addedByAvatar ?? this.addedByAvatar,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
