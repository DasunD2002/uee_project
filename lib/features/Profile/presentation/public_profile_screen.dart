import 'package:flutter/material.dart';
import '../../../core/widgets/feed_post_card.dart';

class PublicProfileScreen extends StatelessWidget {
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
  });
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
                        backgroundImage: AssetImage(avatar),
                      ),
                      const SizedBox(width: 24),
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Count('1', 'Post'),
                            _Count('12.4k', 'Followers'),
                            _Count('286', 'Following'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(handle),
                  const SizedBox(height: 8),
                  Text(
                    author == 'Dinesh'
                        ? 'Traditional mask carver. Sharing the craft, colour and stories of Ambalangoda.'
                        : 'Documenting the temples, textiles and oral histories of Sri Lanka.',
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
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              media: Image.asset(image, fit: BoxFit.cover),
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
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}
