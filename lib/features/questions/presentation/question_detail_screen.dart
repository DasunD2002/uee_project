import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/question.dart';
import '../domain/question_store.dart';
import 'widgets/vote_control.dart';

class QuestionDetailScreen extends StatefulWidget {
  const QuestionDetailScreen({super.key, required this.question});

  final Question question;

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _composerController = TextEditingController();
  final _composerFocus = FocusNode();
  final _answerVoteSelections = <String, int>{};
  final _store = QuestionStore.instance;
  int _questionVoteSelection = 0;
  String _answerSort = 'top';
  String? _replyToId;
  String? _replyToName;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refreshThread);
  }

  void _refreshThread() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_refreshThread);
    _composerController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  Question get _question =>
      _store.questionById(widget.question.id) ?? widget.question;

  List<QuestionAnswer> get _answers {
    final answers = [..._question.answers];
    if (_answerSort == 'top') {
      answers.sort(
        (a, b) => _answerVoteCount(b).compareTo(_answerVoteCount(a)),
      );
    } else {
      return answers.reversed.toList();
    }
    return answers;
  }

  int _answerVoteCount(QuestionAnswer answer) =>
      answer.votes + (_answerVoteSelections[answer.id] ?? 0);

  void _voteQuestion(int direction) {
    setState(() {
      _questionVoteSelection = _questionVoteSelection == direction
          ? 0
          : direction;
    });
  }

  void _voteAnswer(QuestionAnswer answer, int direction) {
    setState(() {
      final current = _answerVoteSelections[answer.id] ?? 0;
      _answerVoteSelections[answer.id] = current == direction ? 0 : direction;
    });
  }

  void _beginReply(QuestionAnswer answer) {
    setState(() {
      _replyToId = answer.id;
      _replyToName = answer.author;
    });
    _composerFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  void _postResponse() {
    final body = _composerController.text.trim();
    if (body.isEmpty) return;
    final parentId = _replyToId;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      _composerController.clear();
      _replyToId = null;
      _replyToName = null;
    });
    _store.addAnswer(
      _question.id,
      QuestionAnswer(
        id: 'community-answer-$timestamp',
        author: 'Amaya Perera',
        authorInitials: 'AP',
        role: 'Local guide',
        timeAgo: 'Just now',
        body: body,
        votes: 0,
      ),
      parentAnswerId: parentId,
    );
    _composerFocus.unfocus();
  }

  void _shareThread() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Thread link ready to share')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final answers = _answers;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2F201B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        titleSpacing: 0,
        title: const Text(
          'Thread',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _bookmarked ? 'Remove bookmark' : 'Bookmark thread',
            onPressed: () => setState(() => _bookmarked = !_bookmarked),
            icon: Icon(
              _bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 21,
            ),
          ),
          IconButton(
            tooltip: 'Share thread',
            onPressed: _shareThread,
            icon: const Icon(Icons.share_outlined, size: 20),
          ),
          const SizedBox(width: 3),
        ],
        shape: const Border(bottom: BorderSide(color: Color(0xFFEDE1D9))),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    _ThreadTag(
                      label: question.location,
                      icon: Icons.location_on_outlined,
                      filled: true,
                    ),
                    _ThreadTag(label: question.category),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  question.title,
                  style: const TextStyle(
                    color: Color(0xFF302019),
                    fontFamily: 'serif',
                    fontSize: 24,
                    height: 1.18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  question.body,
                  style: const TextStyle(
                    color: Color(0xFF806C62),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFFFDFC5),
                      child: Text(
                        question.authorInitials,
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.author,
                            style: const TextStyle(
                              color: Color(0xFF3F2C25),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Local guide · asked ${question.timeAgo}',
                            style: const TextStyle(
                              color: Color(0xFF9A867C),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VoteControl(
                      count: question.votes + _questionVoteSelection,
                      selection: _questionVoteSelection,
                      onUpvote: () => _voteQuestion(1),
                      onDownvote: () => _voteQuestion(-1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  '${question.answers.length} ${question.answers.length == 1 ? 'answer' : 'answers'}',
                  style: const TextStyle(
                    color: Color(0xFF38251E),
                    fontFamily: 'serif',
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                _SortButton(
                  label: 'top',
                  selected: _answerSort == 'top',
                  onTap: () => setState(() => _answerSort = 'top'),
                ),
                const SizedBox(width: 15),
                _SortButton(
                  label: 'new',
                  selected: _answerSort == 'new',
                  onTap: () => setState(() => _answerSort = 'new'),
                ),
              ],
            ),
          ),
          if (answers.isEmpty)
            const _FirstAnswerPrompt()
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                children: [
                  for (final answer in answers)
                    _AnswerThread(
                      key: ValueKey('thread-answer-${answer.id}'),
                      answer: answer,
                      depth: 0,
                      voteCount: _answerVoteCount,
                      voteSelection: (entry) =>
                          _answerVoteSelections[entry.id] ?? 0,
                      onVote: _voteAnswer,
                      onReply: _beginReply,
                    ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: _ThreadComposer(
        controller: _composerController,
        focusNode: _composerFocus,
        replyingTo: _replyToName,
        onCancelReply: _cancelReply,
        onPost: _postResponse,
      ),
    );
  }
}

class _AnswerThread extends StatelessWidget {
  const _AnswerThread({
    super.key,
    required this.answer,
    required this.depth,
    required this.voteCount,
    required this.voteSelection,
    required this.onVote,
    required this.onReply,
  });

  final QuestionAnswer answer;
  final int depth;
  final int Function(QuestionAnswer answer) voteCount;
  final int Function(QuestionAnswer answer) voteSelection;
  final void Function(QuestionAnswer answer, int direction) onVote;
  final ValueChanged<QuestionAnswer> onReply;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(left: depth == 0 ? 0 : 11, bottom: 15),
    padding: EdgeInsets.only(left: depth == 0 ? 0 : 11),
    decoration: depth == 0
        ? null
        : const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFFE7DAD1))),
          ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: depth == 0 ? 12 : 11,
              backgroundColor: depth == 0
                  ? AppColors.brown
                  : const Color(0xFFFFDFC7),
              child: Text(
                answer.authorInitials,
                style: TextStyle(
                  color: depth == 0 ? Colors.white : AppColors.brown,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    answer.author,
                    style: const TextStyle(
                      color: Color(0xFF3F2B23),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (answer.role.isNotEmpty) _RoleTag(answer.role),
                  Text(
                    '· ${answer.timeAgo}',
                    style: const TextStyle(
                      color: Color(0xFFA28E84),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE7D8CE)),
              ),
              child: const Icon(
                Icons.remove_rounded,
                color: Color(0xFF8D786E),
                size: 14,
              ),
            ),
          ],
        ),
        if (answer.isVerified) ...[
          const SizedBox(height: 7),
          const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.brown,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                'Verified by heritage keeper',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          answer.body,
          style: const TextStyle(
            color: Color(0xFF49362F),
            fontSize: 12,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            VoteControl(
              count: voteCount(answer),
              selection: voteSelection(answer),
              onUpvote: () => onVote(answer, 1),
              onDownvote: () => onVote(answer, -1),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              key: ValueKey('reply-${answer.id}'),
              onPressed: () => onReply(answer),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF806B61),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 15,
              ),
              label: const Text('Reply', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
        for (final reply in answer.replies)
          _AnswerThread(
            key: ValueKey('thread-answer-${reply.id}'),
            answer: reply,
            depth: depth + 1,
            voteCount: voteCount,
            voteSelection: voteSelection,
            onVote: onVote,
            onReply: onReply,
          ),
      ],
    ),
  );
}

class _ThreadComposer extends StatelessWidget {
  const _ThreadComposer({
    required this.controller,
    required this.focusNode,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onPost,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 10,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to $replyingTo',
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      key: const ValueKey('cancel-reply'),
                      onTap: onCancelReply,
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('answer-composer'),
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? 'Share what you know...'
                          : 'Write a reply...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA5ADBD),
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFFCF8),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Color(0xFFE6D7CD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.brown),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 42,
                  child: FilledButton(
                    key: const ValueKey('post-answer-button'),
                    onPressed: onPost,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE8D9C6),
                      foregroundColor: const Color(0xFF8F7B70),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(replyingTo == null ? 'Answer' : 'Reply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.brown : const Color(0xFF8D7A70),
          fontSize: 10,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    ),
  );
}

class _RoleTag extends StatelessWidget {
  const _RoleTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEAD9),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: const TextStyle(color: AppColors.brown, fontSize: 8),
    ),
  );
}

class _FirstAnswerPrompt extends StatelessWidget {
  const _FirstAnswerPrompt();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(16, 28, 16, 60),
    child: Column(
      children: [
        Icon(Icons.forum_outlined, color: Color(0xFFB59E92), size: 31),
        SizedBox(height: 8),
        Text(
          'No answers yet. Share what you know.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF806C62), fontSize: 12),
        ),
      ],
    ),
  );
}

class _ThreadTag extends StatelessWidget {
  const _ThreadTag({required this.label, this.icon, this.filled = false});

  final String label;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: filled ? const Color(0xFFFFDFC5) : Colors.white,
      border: filled ? null : Border.all(color: const Color(0xFFE7D8CE)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.brown, size: 12),
          const SizedBox(width: 3),
        ],
        Text(
          label,
          style: TextStyle(
            color: filled ? AppColors.brown : const Color(0xFF806E65),
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}
