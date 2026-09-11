import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../domain/question.dart';
import '../domain/question_store.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  static const _places = <String>[
    'Polonnaruwa',
    'Gal Vihara',
    'Anuradhapura',
    'Sigiriya',
    'Kandy',
  ];
  static const _topics = <String>[
    'Rituals & Etiquette',
    'Architecture',
    'Language',
    'Getting There',
    'Folklore',
  ];

  final _questionController = TextEditingController();
  final _contextController = TextEditingController();
  String _place = _places.first;
  String _topic = _topics.first;

  bool get _canPost =>
      _questionController.text.trim().length >= 10 &&
      _contextController.text.trim().length >= 20;

  @override
  void dispose() {
    _questionController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _refreshForm(String _) => setState(() {});

  void _postQuestion() {
    if (!_canPost) return;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    QuestionStore.instance.addQuestion(
      Question(
        id: 'community-question-$timestamp',
        title: _questionController.text.trim(),
        body: _contextController.text.trim(),
        location: _place,
        category: _topic,
        timeAgo: 'Just now',
        author: 'Amaya Perera',
        authorInitials: 'AP',
        votes: 0,
        answers: const [],
        isVerified: false,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
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
          'Ask the community',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: const Border(bottom: BorderSide(color: Color(0xFFEDE1D9))),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBD9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.brown,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Questions tied to a specific place get answered fastest — heritage keepers follow the sites they know.',
                    style: TextStyle(
                      color: Color(0xFF6F3224),
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Your question'),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('new-question-title'),
            controller: _questionController,
            onChanged: _refreshForm,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              color: Color(0xFF3E2C25),
              fontFamily: 'serif',
              fontSize: 16,
            ),
            decoration: _fieldDecoration(
              'What is the correct way to...',
              italicHint: true,
            ),
          ),
          const SizedBox(height: 17),
          const _FieldLabel('Add context'),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('new-question-context'),
            controller: _contextController,
            onChanged: _refreshForm,
            minLines: 5,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              color: Color(0xFF4B3931),
              fontSize: 13,
              height: 1.45,
            ),
            decoration: _fieldDecoration(
              'Where were you, what did you see, and what part is unclear?',
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Place'),
          const SizedBox(height: 7),
          SizedBox(
            height: 34,
            child: ListView.separated(
              key: const ValueKey('question-place-options'),
              scrollDirection: Axis.horizontal,
              itemCount: _places.length,
              separatorBuilder: (_, _) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final place = _places[index];
                return _SelectionChip(
                  label: place,
                  selected: _place == place,
                  icon: Icons.location_on_outlined,
                  onSelected: () => setState(() => _place = place),
                );
              },
            ),
          ),
          const SizedBox(height: 13),
          const _FieldLabel('Topic'),
          const SizedBox(height: 7),
          Wrap(
            key: const ValueKey('question-topic-options'),
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final topic in _topics)
                _SelectionChip(
                  label: topic,
                  selected: _topic == topic,
                  onSelected: () => setState(() => _topic = topic),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8DBD2))),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    key: const ValueKey('post-question-button'),
                    onPressed: _canPost ? _postQuestion : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brown,
                      disabledBackgroundColor: const Color(0xFFE7D9C6),
                      disabledForegroundColor: const Color(0xFFAD968A),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Post question',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _canPost
                      ? 'Ready to share with the community'
                      : 'Write a little more to post',
                  style: const TextStyle(color: Color(0xFFA38F84), fontSize: 9),
                ),
              ],
            ),
          ),
          if (!keyboardOpen)
            ExplorerFooter(
              selectedIndex: 2,
              onSelected: (index) =>
                  navigateToPrimaryDestination(context, index),
            ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, {bool italicHint = false}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFA5ADBD),
          fontFamily: italicHint ? 'serif' : null,
          fontStyle: italicHint ? FontStyle.italic : FontStyle.normal,
          fontSize: italicHint ? 15 : 12,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6D7CD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brown),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: Color(0xFF78645A),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 13), const SizedBox(width: 3)],
        Text(label),
      ],
    ),
    selected: selected,
    showCheckmark: false,
    onSelected: (_) => onSelected(),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    side: BorderSide(
      color: selected ? AppColors.brown : const Color(0xFFE7D8CE),
    ),
    backgroundColor: Colors.white,
    selectedColor: AppColors.brown,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    labelStyle: TextStyle(
      color: selected ? Colors.white : const Color(0xFF735E54),
      fontSize: 10,
    ),
  );
}
