import 'package:flutter/material.dart';
import '../../../../core/widgets/feed_post_card.dart';
import '../../../Profile/presentation/public_profile_screen.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
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
  });
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
    media: Image.asset(imagePath, fit: BoxFit.cover),
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
  );
}
