import 'post_comments_sheet.dart';
import '../../features/Post Creation/presentation/post_details_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'post_interaction_sheets.dart';
import '../../features/Profile/domain/social_store.dart';

class FeedPostCard extends StatefulWidget {
  const FeedPostCard({
    super.key,
    required this.media,
    required this.category,
    required this.title,
    required this.location,
    required this.description,
    required this.likes,
    required this.comments,
    this.author = 'Amaya',
    this.handle = '@amaya.heritage',
    this.time = '6h',
    this.avatar = 'assets/images/profile_avatar.png',
    this.onEdit,
    this.onAuthorTap,
    this.isDetail = false,
    this.detailFields = const {},
    this.proofs = const [],
    this.commentsDisabled = false,
    this.margin = EdgeInsets.zero,
  });
  final Widget media;
  final String category,
      title,
      location,
      description,
      likes,
      comments,
      author,
      handle,
      time,
      avatar;
  final VoidCallback? onEdit, onAuthorTap;
  final bool commentsDisabled, isDetail;
  final Map<String, String> detailFields;
  final List<Widget> proofs;
  final EdgeInsets margin;
  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool expanded = false, showHeart = false;
  final comment = TextEditingController();
  String get postId => '${widget.handle}:${widget.title}';
  bool get liked => SocialStore.instance.likedPosts.contains(postId);
  bool get saved => SocialStore.instance.isSaved(postId);
  List<String> get addedComments =>
      SocialStore.instance.comments.putIfAbsent(postId, () => []);
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  void toggleLike() => setState(() {
    if (liked) {
      SocialStore.instance.likedPosts.remove(postId);
    } else {
      SocialStore.instance.likedPosts.add(postId);
    }
  });
  Future<void> doubleLike() async {
    setState(() {
      SocialStore.instance.likedPosts.add(postId);
      showHeart = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() => showHeart = false);
  }

  Future<void> saveCollections() async {
    await chooseSavedCollections(
      context,
      SavedStory(
        id: postId,
        title: widget.title,
        author: widget.author,
        description: widget.description,
      ),
    );
    if (mounted) setState(() {});
  }

  String count(String value, int extra) {
    final number = int.tryParse(value.replaceAll(',', ''));
    if (number == null || extra == 0) return value;
    return (number + extra).toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void submitComment() {
    if (comment.text.trim().isEmpty) return;
    setState(() {
      addedComments.add(comment.text.trim());
      comment.clear();
    });
  }

  Future<void> openComments() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => PostCommentsSheet(
        comments: addedComments,
        onSend: (text) {
          setState(() => addedComments.add(text));
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> openDetails() async {
    if (widget.isDetail) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (detailContext) => PostDetailsScreen(
          post: FeedPostCard(
            isDetail: true,
            media: widget.media,
            category: widget.category,
            title: widget.title,
            location: widget.location,
            description: widget.description,
            likes: widget.likes,
            comments: widget.comments,
            author: widget.author,
            handle: widget.handle,
            time: widget.time,
            avatar: widget.avatar,
            commentsDisabled: widget.commentsDisabled,
            detailFields: widget.detailFields,
            proofs: widget.proofs,
            onAuthorTap: widget.onAuthorTap,
            onEdit: widget.onEdit == null
                ? null
                : () {
                    Navigator.pop(detailContext);
                    widget.onEdit!();
                  },
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.isDetail ? null : openDetails,
    child: Card(
      margin: widget.margin,
      elevation: 1.5,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE8E4E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onAuthorTap,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(widget.avatar),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${widget.author} ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.handle,
                                      style: const TextStyle(
                                        color: Color(0xFF645F5B),
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.location} · ${widget.time}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF645F5B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Post options',
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (_) => reportPost(context, postId),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report the post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: widget.isDetail ? null : openDetails,
                onDoubleTap: doubleLike,
                child: AspectRatio(aspectRatio: 1.55, child: widget.media),
              ),
              if (showHeart)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 86,
                        shadows: [
                          Shadow(blurRadius: 14, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3CA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (widget.onEdit != null)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: SizedBox(
                    height: 30,
                    child: FilledButton.icon(
                      onPressed: widget.onEdit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFDABB),
                        foregroundColor: AppColors.brown,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text(
                        'Edit post',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: liked ? 'Unlike post' : 'Like post',
                      onPressed: toggleLike,
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.brown,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Comment',
                      onPressed: widget.commentsDisabled ? null : openComments,
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.brown,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: saved ? 'Unsave post' : 'Save post',
                      onPressed: saveCollections,
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                        color: AppColors.brown,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${count(widget.likes, liked ? 1 : 0)} Likes · ${widget.commentsDisabled ? 'Comments off' : '${count(widget.comments, addedComments.length)} Comments'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.description,
                  maxLines: widget.isDetail || expanded ? null : 2,
                  overflow: widget.isDetail || expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                if (!widget.isDetail && widget.description.isNotEmpty)
                  InkWell(
                    onTap: () => setState(() => expanded = !expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        expanded ? 'See less' : '...see more',
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (widget.isDetail) ...[
                  const Divider(height: 28),
                  for (final field in {
                    'Category': widget.category,
                    'Location': widget.location,
                    'Published': widget.time,
                    ...widget.detailFields,
                  }.entries)
                    if (field.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${field.key}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: field.value),
                            ],
                          ),
                        ),
                      ),
                  if (widget.proofs.isNotEmpty) ...[
                    const Text(
                      'Supporting photos & videos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...widget.proofs,
                  ],
                  if (!widget.commentsDisabled)
                    TextButton.icon(
                      onPressed: openComments,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('View all comments'),
                    ),
                ],
                if (!widget.commentsDisabled) ...[
                  for (final text in addedComments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'You ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: text),
                          ],
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage(
                          'assets/images/profile_avatar.png',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: comment,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => submitComment(),
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: const Color(0xFFF0EEEE),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              tooltip: 'Post comment',
                              icon: const Icon(Icons.arrow_upward, size: 18),
                              onPressed: submitComment,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
