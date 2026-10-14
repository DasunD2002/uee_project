import 'dart:typed_data';

class PostMedia {
  const PostMedia({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
  bool get isVideo => name.toLowerCase().endsWith('.mp4');
}

class UserPost {
  UserPost({
    required this.id,
    required this.title,
    required this.story,
    this.category = 'Heritage Site',
    this.place = 'Sigiriya Rock Fortress',
    this.district = 'Matale',
    this.language = 'English',
    this.tags = const [],
    this.asset = 'assets/images/login_image.jpg',
    this.cover,
    this.proofs = const [],
    this.disableComments = false,
    this.isPrivate = false,
    this.isDraft = false,
    this.isLiked = false,
    this.authorName = 'Unknown User',
    this.authorHandle = '@unknown',
    this.authorId = '',
    this.authorPhoto,
    this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.comments = const [],
  });
  final String id,
      title,
      story,
      category,
      place,
      district,
      language,
      asset,
      authorName,
      authorHandle,
      authorId;
  final String? authorPhoto;
  final DateTime? createdAt;
  final int likeCount, commentCount;
  final List<String> tags;
  final PostMedia? cover;
  final List<PostMedia> proofs;
  final List<UserComment> comments;
  final bool disableComments, isPrivate, isDraft, isLiked;

  factory UserPost.fromJson(Map<String, dynamic> json) {
    String p = 'Unknown';
    String d = 'Unknown';
    if (json['location'] != null) {
      final loc = json['location'].toString().split(',');
      if (loc.isNotEmpty) p = loc[0].trim();
      if (loc.length > 1) d = loc[1].trim();
    }
    return UserPost(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      story: json['story'] ?? '',
      category: json['category'] ?? '',
      place: p,
      district: d,
      language: '',
      tags: List<String>.from(json['tags'] ?? []),
      asset: json['media'] ?? '',
      disableComments: json['disableComments'] ?? false,
      isPrivate: json['visibility'] == 'private',
      isDraft: json['isDraft'] == true,
      authorName: json['authorName'] ?? 'Unknown User',
      authorHandle: json['authorHandle'] ?? '@unknown',
      authorPhoto: json['authorPhoto'],
      authorId: json['userId'] ?? '',
      isLiked: json['isLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      comments:
          (json['comments'] as List?)
              ?.map((e) => UserComment.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UserComment {
  const UserComment({
    required this.userId,
    required this.text,
    required this.authorName,
    this.authorPhoto,
    this.createdAt,
  });
  final String userId, text, authorName;
  final String? authorPhoto;
  final DateTime? createdAt;

  factory UserComment.fromJson(Map<String, dynamic> json) => UserComment(
    userId: json['userId'] ?? '',
    text: json['text'] ?? '',
    authorName: json['authorName'] ?? 'Unknown User',
    authorPhoto: json['authorPhoto'],
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null,
  );
}

class PostEditorResult {
  const PostEditorResult({this.post, this.deleted = false});
  final UserPost? post;
  final bool deleted;
}
