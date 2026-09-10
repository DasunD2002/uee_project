import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({
    super.key,
    required this.comments,
    required this.onSend,
  });
  final List<String> comments;
  final ValueChanged<String> onSend;
  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final composer = TextEditingController();
  final focus = FocusNode();
  final scroll = ScrollController();
  String? replyTo;
  @override
  void dispose() {
    composer.dispose();
    focus.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    final text = composer.text.trim();
    if (text.isEmpty) return;
    widget.onSend(replyTo == null ? text : '@$replyTo $text');
    setState(() {
      composer.clear();
      replyTo = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .72,
      child: Column(
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              children: [
                _Comment(
                  name: 'Nimal',
                  text: 'Thank you for sharing the story behind this place!',
                  onReply: () {
                    setState(() => replyTo = 'Nimal');
                    focus.requestFocus();
                  },
                ),
                _Comment(
                  name: 'Sanduni',
                  text: 'Love seeing our heritage celebrated.',
                  onReply: () {
                    setState(() => replyTo = 'Sanduni');
                    focus.requestFocus();
                  },
                ),
                for (var i = 0; i < widget.comments.length; i++)
                  _Comment(
                    key: ValueKey('sent-$i'),
                    name: 'You',
                    text: widget.comments[i],
                    mine: true,
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final emoji in ['❤️', '🙌', '🔥', '👏', '😍', '✨'])
                TextButton(
                  onPressed: () {
                    composer.text += emoji;
                    composer.selection = TextSelection.collapsed(
                      offset: composer.text.length,
                    );
                    focus.requestFocus();
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 21)),
                ),
            ],
          ),
          if (replyTo != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to $replyTo',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel reply',
                    onPressed: () => setState(() => replyTo = null),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(
                    'assets/images/profile_avatar.png',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: composer,
                    focusNode: focus,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => send(),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFDFDFDF)),
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Send comment',
                        onPressed: send,
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Comment extends StatefulWidget {
  const _Comment({
    super.key,
    required this.name,
    required this.text,
    this.mine = false,
    this.onReply,
  });
  final String name, text;
  final bool mine;
  final VoidCallback? onReply;
  @override
  State<_Comment> createState() => _CommentState();
}

class _CommentState extends State<_Comment> {
  bool liked = false;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.mine) const SizedBox(width: 24),
        if (!widget.mine) ...[
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFE2DCF5),
            child: Text(widget.name[0]),
          ),
          const SizedBox(width: 9),
        ],
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            decoration: BoxDecoration(
              color: widget.mine
                  ? const Color(0xFFFFE1CC)
                  : const Color(0xFFF1EDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.mine ? 'Now' : '2h',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.text,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                if (widget.onReply != null)
                  InkWell(
                    onTap: widget.onReply,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Like comment',
          onPressed: () => setState(() => liked = !liked),
          visualDensity: VisualDensity.compact,
          icon: Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: liked ? AppColors.brown : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
