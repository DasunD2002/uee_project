import 'package:flutter/material.dart';
import '../domain/user_post.dart';
import 'create_post_screen.dart';

class EditPostScreen extends StatelessWidget {
  const EditPostScreen({super.key, required this.post});
  final UserPost post;
  @override
  Widget build(BuildContext context) => CreatePostScreen(post: post);
}
