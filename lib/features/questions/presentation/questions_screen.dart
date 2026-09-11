import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../domain/question.dart';
import '../domain/question_store.dart';
import 'widgets/question_app_bar.dart';
import 'widgets/vote_control.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  static const _categories = <String>[
    'All',
    'Rituals & Etiquette',
    'Architecture',
    'Language',
    'History',
    'Crafts',
    'Getting There',
    'Folklore',
  ];
  static const _sorts = <String>['Top', 'New', 'Unanswered'];

  final _searchController = TextEditingController();
  final _voteSelections = <String, int>{};
  final _store = QuestionStore.instance;
  String _category = 'All';
  String _sort = 'Top';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _store.addListener(_refreshQuestions);
  }

  void _refreshQuestions() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_refreshQuestions);
    _searchController.dispose();
    super.dispose();
  }

  List<Question> get _visibleQuestions {
    final query = _query.trim().toLowerCase();
    final questions = _store.questions.where((question) {
      final matchesCategory =
          _category == 'All' || question.category == _category;
      final searchable = <String>[
        question.title,
        question.body,
        question.location,
        question.category,
      ].join(' ').toLowerCase();
      final matchesQuery = query.isEmpty || searchable.contains(query);
      final matchesSort = _sort != 'Unanswered' || question.answers.isEmpty;
      return matchesCategory && matchesQuery && matchesSort;
    }).toList();
    if (_sort == 'Top') {
      questions.sort((a, b) => _voteCount(b).compareTo(_voteCount(a)));
    }
    return questions;
  }

  int _voteCount(Question question) =>
      question.votes + (_voteSelections[question.id] ?? 0);

  void _vote(Question question, int direction) {
    setState(() {
      final current = _voteSelections[question.id] ?? 0;
      _voteSelections[question.id] = current == direction ? 0 : direction;
    });
  }

  void _openQuestion(Question question) =>
      Navigator.pushNamed(context, '/question-detail', arguments: question);

  Future<void> _askQuestion() async {
    final posted = await Navigator.pushNamed(context, '/ask-question');
    if (posted == true && mounted) setState(() => _sort = 'New');
  }

  void _onNavigationSelected(int index) {
    if (index == 2) return;
    final route = switch (index) {
      0 => '/home',
      1 => '/explorer',
      _ => '/capsule',
    };
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final questions = _visibleQuestions;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const HomeDrawer(selectedSection: 'Q&A Forum'),
      appBar: const QuestionAppBar(),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: _QuestionFilters(
              searchController: _searchController,
              categories: _categories,
              sorts: _sorts,
              selectedCategory: _category,
              selectedSort: _sort,
              threadCount: questions.length,
              onSearchChanged: (value) => setState(() => _query = value),
              onCategorySelected: (value) => setState(() => _category = value),
              onSortSelected: (value) => setState(() => _sort = value),
            ),
          ),
          if (questions.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyQuestions(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
              sliver: SliverList.separated(
                itemCount: questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 13),
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return QuestionCard(
                    key: ValueKey('question-${question.id}'),
                    question: question,
                    voteCount: _voteCount(question),
                    voteSelection: _voteSelections[question.id] ?? 0,
                    onTap: () => _openQuestion(question),
                    onUpvote: () => _vote(question, 1),
                    onDownvote: () => _vote(question, -1),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('ask-question-button'),
        heroTag: 'ask-question',
        onPressed: _askQuestion,
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text('Ask', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 2,
        onSelected: _onNavigationSelected,
      ),
    );
  }
}

class _QuestionFilters extends StatelessWidget {
  const _QuestionFilters({
    required this.searchController,
    required this.categories,
    required this.sorts,
    required this.selectedCategory,
    required this.selectedSort,
    required this.threadCount,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onSortSelected,
  });

  final TextEditingController searchController;
  final List<String> categories;
  final List<String> sorts;
  final String selectedCategory;
  final String selectedSort;
  final int threadCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSortSelected;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFFFFFCF9),
      border: Border(bottom: BorderSide(color: Color(0xFFE9DDD5))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 11),
          child: Text(
            'Ask the people who know these places',
            style: TextStyle(
              color: Color(0xFF8B776E),
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 40,
            child: TextField(
              key: const ValueKey('question-search'),
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search questions, places, customs',
                hintStyle: const TextStyle(
                  color: Color(0xFFA8A8B6),
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: Color(0xFFAA998F),
                ),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close, size: 17),
                      ),
                filled: true,
                fillColor: const Color(0xFFFFFBF7),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: Color(0xFFE8D9CF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: AppColors.brown),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            key: const ValueKey('question-categories'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = category == selectedCategory;
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => onCategorySelected(category),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: selected ? AppColors.brown : const Color(0xFFE8D9CF),
                ),
                backgroundColor: const Color(0xFFFFFBF7),
                selectedColor: AppColors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF6F5C54),
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 9),
          child: Row(
            children: [
              for (final sort in sorts)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    key: ValueKey('sort-${sort.toLowerCase()}'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSortSelected(sort),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        sort,
                        style: TextStyle(
                          color: sort == selectedSort
                              ? AppColors.brown
                              : const Color(0xFF766861),
                          fontSize: 11,
                          fontWeight: sort == selectedSort
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '$threadCount ${threadCount == 1 ? 'thread' : 'threads'}',
                style: const TextStyle(color: Color(0xFFA69389), fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.voteCount,
    required this.voteSelection,
    required this.onTap,
    required this.onUpvote,
    required this.onDownvote,
  });

  final Question question;
  final int voteCount;
  final int voteSelection;
  final VoidCallback onTap;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFFEFD),
    elevation: 3,
    shadowColor: const Color(0x2B6A3F2F),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9DCD4)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 7,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Tag(
                  label: question.location,
                  icon: Icons.location_on_outlined,
                  filled: true,
                ),
                _Tag(label: question.category),
                Text(
                  question.timeAgo,
                  style: const TextStyle(
                    color: Color(0xFF88766D),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF37231C),
                fontFamily: 'serif',
                fontSize: 19,
                height: 1.18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              question.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF826F65),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 9,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                VoteControl(
                  count: voteCount,
                  selection: voteSelection,
                  onUpvote: onUpvote,
                  onDownvote: onDownvote,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 17,
                      color: Color(0xFF826F65),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${question.answers.length} ${question.answers.length == 1 ? 'answer' : 'answers'}',
                      style: const TextStyle(
                        color: Color(0xFF6E5B52),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (question.isVerified)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 17,
                        color: AppColors.brown,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                CircleAvatar(
                  radius: 11,
                  backgroundColor: const Color(0xFFFFE3CD),
                  child: Text(
                    question.authorInitials,
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.icon, this.filled = false});

  final String label;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 150),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: filled ? const Color(0xFFFFE0C7) : const Color(0xFFFFFEFC),
      border: filled ? null : Border.all(color: const Color(0xFFE8D8CD)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.brown, size: 12),
          const SizedBox(width: 3),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: filled ? AppColors.brown : const Color(0xFF806E65),
              fontSize: 9,
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyQuestions extends StatelessWidget {
  const _EmptyQuestions();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, color: Color(0xFFB79F92), size: 38),
          SizedBox(height: 10),
          Text(
            'No questions found',
            style: TextStyle(
              color: Color(0xFF4B332A),
              fontFamily: 'serif',
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try another search or start a new thread.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF88766D), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
