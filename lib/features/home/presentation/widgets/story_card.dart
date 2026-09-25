import 'package:flutter/material.dart';
import '../../../Post Creation/domain/user_post.dart';
import '../../../../core/widgets/feed_post_card.dart';
import '../../../Profile/presentation/public_profile_screen.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.postId,
    required this.category,
    required this.imagePath,
    required this.title,
    required this.location,
    required this.description,
    required this.likes,
    required this.comments,
    this.author = 'Amaya',
    this.handle = '@amaya.heritage',
    this.time = '6h',
    this.postComments = const [],
  });
  final String postId;
  final List<UserComment> postComments;
  final String category,
      imagePath,
      title,
      location,
      description,
      likes,
      comments,
      author,
      handle,
      time;
  @override
  Widget build(BuildContext context) => FeedPostCard(
    postId: postId,
    onAuthorTap: () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PublicProfileScreen(
          author: author,
          handle: handle,
          avatar: author == 'Dinesh'
              ? 'assets/images/dinesh_avatar.png'
              : 'assets/images/profile_avatar.png',
          image: imagePath,
          title: title,
          location: location,
          description: description,
          category: category,
          likes: likes,
          comments: comments,
        ),
      ),
    ),
    media: imagePath.toLowerCase().endsWith('.mp4')
        ? Container(
            color: const Color(0xFFFFF5EC),
            child: const Icon(Icons.video_file_outlined, size: 52),
          )
        : imagePath.startsWith('http')
            ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
            : Image.asset(imagePath, fit: BoxFit.cover),
    category: category,
    title: title,
    location: location,
    description: description,
    likes: likes,
    comments: comments,
    author: author,
    avatar: author == 'Dinesh'
        ? 'assets/images/dinesh_avatar.png'
        : 'assets/images/profile_avatar.png',
    handle: handle,
    time: time,
    postComments: postComments,
  );
}
