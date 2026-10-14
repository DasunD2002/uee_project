import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/feed_post_card.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.author,
    required this.handle,
    required this.avatar,
    required this.image,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.likes,
    required this.comments,
    this.authorId = '',
    this.postId = '',
  });
  final String authorId, postId;
  final String author,
      handle,
      avatar,
      image,
      title,
      location,
      description,
      category,
      likes,
      comments;
  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool following = false, saving = false;
  int followers = 0, followingCount = 0;
  String get author => widget.author;
  String get handle => widget.handle;
  String get avatar => widget.avatar;
  String get image => widget.image;
  String get title => widget.title;
  String get location => widget.location;
  String get description => widget.description;
  String get category => widget.category;
  String get likes => widget.likes;
  String get comments => widget.comments;
  @override
  void initState() {
    super.initState();
    if (widget.authorId.isNotEmpty) _load();
  }

  void _apply(Map<String, dynamic> data) {
    following = data['following'] as bool? ?? false;
    followers = (data['followerCount'] as num?)?.toInt() ?? 0;
    followingCount = (data['followingCount'] as num?)?.toInt() ?? 0;
  }

  Future<void> _load() async {
    try {
      final response = await ApiService().get(
        '/users/${widget.authorId}/follow',
      );
      if (response.statusCode != 200) {
        throw StateError('Could not load this profile.');
      }
      if (mounted) {
        setState(
          () =>
              _apply(jsonDecode(response.body)['data'] as Map<String, dynamic>),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _follow() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final response = await ApiService().put(
        '/users/${widget.authorId}/follow',
        body: {'following': !following},
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw StateError(
          body['errorDescription'] ?? 'Could not update following.',
        );
      }
      if (mounted) {
        setState(() => _apply(body['data'] as Map<String, dynamic>));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
          Text(following ? 'You are now following $author' : 'You unfollowed $author')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: Text(handle), centerTitle: true),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: avatar.isEmpty
                            ? null
                            : avatar.startsWith('http')
                            ? NetworkImage(avatar)
                            : AssetImage(avatar) as ImageProvider,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const _Count('1', 'Preview'),
                            _Count(followers.toString(), 'Followers'),
                            _Count(followingCount.toString(), 'Following'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton(
                        onPressed: saving || widget.authorId.isEmpty
                            ? null
                            : _follow,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF9E4B33),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(80, 36),
                        ),
                        child: Text(
                          following ? 'Following' : 'Follow',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(handle),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(location, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Posts',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            FeedPostCard(
              postId: widget.postId,
              authorId: widget.authorId,
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              media: image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported),
                    ),
              category: category,
              title: title,
              location: location,
              description: description,
              likes: likes,
              comments: comments,
              author: author,
              handle: handle,
              avatar: avatar,
            ),
          ],
        ),
      ),
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
    ],
  ));
}
