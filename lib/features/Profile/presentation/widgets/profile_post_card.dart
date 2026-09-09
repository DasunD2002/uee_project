import 'package:flutter/material.dart';
import '../../../../core/widgets/feed_post_card.dart';
import '../../../Post Creation/domain/user_post.dart';

class ProfilePostCard extends StatelessWidget {
  const ProfilePostCard({super.key, required this.post, required this.onEdit});
  final UserPost post;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => FeedPostCard(
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
        : Image.asset(post.asset, fit: BoxFit.cover),
    category: post.isDraft
        ? 'Draft'
        : post.isPrivate
        ? 'Private · ${post.category}'
        : post.category,
    title: post.title.isEmpty ? 'Untitled draft' : post.title,
    location: '${post.place} · ${post.district}',
    description: post.story,
    likes: '1,284',
    comments: '96',
    commentsDisabled: post.disableComments,
    time: post.isDraft ? 'Draft' : '2h',
    onEdit: onEdit,
  );
}
