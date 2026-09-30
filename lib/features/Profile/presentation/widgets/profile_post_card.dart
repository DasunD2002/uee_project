import 'package:flutter/material.dart';
import '../../../../core/widgets/feed_post_card.dart';
import '../../../Post Creation/domain/user_post.dart';

class ProfilePostCard extends StatelessWidget {
  const ProfilePostCard({super.key, required this.post, this.onEdit, this.onDelete});
  final UserPost post;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) => FeedPostCard(
    postId: post.id,
    detailFields: {
      'Language': post.language,
      'Tags': post.tags.map((t) => '#$t').join(' '),
      'Visibility': post.isPrivate ? 'Private' : 'Public',
    },
    proofs: [
      for (final proof in post.proofs)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: proof.isVideo
              ? ListTile(
                  leading: const Icon(Icons.video_file_outlined),
                  title: Text(proof.name),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(proof.bytes, fit: BoxFit.contain),
                ),
        ),
    ],
    margin: const EdgeInsets.fromLTRB(6, 0, 6, 16),
    media: post.cover != null
        ? post.cover!.isVideo
              ? Container(
                  color: const Color(0xFFFFF5EC),
                  child: const Icon(Icons.video_file_outlined, size: 52),
                )
              : Image.memory(post.cover!.bytes, fit: BoxFit.cover)
        : post.asset.isEmpty
        ? Container(
            color: const Color(0xFFFFF5EC),
            child: const Icon(Icons.image_outlined, size: 52),
          )
        : post.asset.toLowerCase().endsWith('.mp4')
            ? Container(
                color: const Color(0xFFFFF5EC),
                child: const Icon(Icons.video_file_outlined, size: 52),
              )
            : post.asset.startsWith('http')
                ? Image.network(post.asset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                : Image.asset(post.asset, fit: BoxFit.cover),
    category: post.isDraft
        ? 'Draft'
        : post.isPrivate
        ? 'Private · ${post.category}'
        : post.category,
    title: post.title.isEmpty ? 'Untitled draft' : post.title,
    location: '${post.place} · ${post.district}',
    description: post.story,
    likes: post.likeCount.toString(),
    comments: post.commentCount.toString(),
    commentsDisabled: post.disableComments,
    postComments: post.comments,
    time: post.isDraft ? 'Draft' : (post.createdAt != null ? '${DateTime.now().difference(post.createdAt!).inHours}h' : 'now'),
    author: post.authorName,
    handle: post.authorHandle,
    avatar: post.authorPhoto ?? '',
    onEdit: onEdit,
    onDelete: onDelete,
  );
}
