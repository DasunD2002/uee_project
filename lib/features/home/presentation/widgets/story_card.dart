import 'package:flutter/material.dart';
import '../../../Post Creation/domain/user_post.dart';
import '../../../../core/widgets/feed_post_card.dart';
import '../../../Profile/presentation/public_profile_screen.dart';
import '../../../Profile/data/user_service.dart';

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
    this.authorId = '',
    this.authorPhoto,
    this.time = '6h',
    this.postComments = const [],
  });
  final String postId;
  final String? authorPhoto;
  final String authorId;
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
    onAuthorTap: () {
      if (authorId == UserService.cachedUserId) {
        Navigator.pushNamed(context, '/profile');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PublicProfileScreen(
              authorId: authorId,
              postId: postId,
              author: author,
              handle: handle,
              avatar: authorPhoto ?? '',
              image: imagePath,
              title: title,
              location: location,
              description: description,
              category: category,
              likes: likes,
              comments: comments,
            ),
          ),
        );
      }
    },
    media: imagePath.toLowerCase().endsWith('.mp4')
        ? Container(
            color: const Color(0xFFFFF5EC),
            child: const Icon(Icons.video_file_outlined, size: 52),
          )
        : imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          )
        : Image.asset(imagePath, fit: BoxFit.cover),
    category: category,
    title: title,
    location: location,
    description: description,
    likes: likes,
    comments: comments,
    author: author,
    avatar: authorPhoto ?? '',
    handle: handle,
    authorId: authorId,
    time: time,
    postComments: postComments,
  );
}
