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
  });
  final String id, title, story, category, place, district, language, asset;
  final List<String> tags;
  final PostMedia? cover;
  final List<PostMedia> proofs;
  final bool disableComments, isPrivate, isDraft;
}

class PostEditorResult {
  const PostEditorResult({this.post, this.deleted = false});
  final UserPost? post;
  final bool deleted;
}
