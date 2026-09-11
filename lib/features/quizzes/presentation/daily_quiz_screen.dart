import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../domain/quiz_progress_store.dart';

const _quizBackground = Colors.white;
const _quizSurface = Color(0xFFFFFCF8);
const _quizPeach = Color(0xFFFFEBD8);
const _quizLine = Color(0xFFEBDACB);
const _quizMuted = Color(0xFF8C766B);

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  final progress = QuizProgressStore.instance;
  final builderLetters = const ['P', 'S', 'A', 'T', 'U'];
  final fillLetters = const ['G', 'I', 'R', 'A', 'Y', 'I', 'N'];

  late int stage;
  final List<int> builderSelection = [];
  final List<int> fillSelection = [];
  int? meaningSelection;
  String? feedback;
  bool transitioning = false;

  @override
  void initState() {
    super.initState();
    stage = progress.completedSteps.clamp(0, 2);
  }

  void _navigate(int index) => navigateToPrimaryDestination(context, index);

  Future<void> _completeStage() async {
    if (transitioning) return;
    transitioning = true;
    final scores = [40, 70, 100];
    progress.completeStep(step: stage + 1, score: scores[stage]);
    setState(() => feedback = 'Correct!');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    if (stage == 2) {
      Navigator.pop(context, progress.score);
      return;
    }
    setState(() {
      stage += 1;
      feedback = null;
      transitioning = false;
    });
  }

  Future<void> _addBuilderLetter(int index) async {
    if (transitioning || builderSelection.contains(index)) return;
    setState(() {
      builderSelection.add(index);
      feedback = null;
    });
    if (builderSelection.length != builderLetters.length) return;
    final answer = builderSelection.map((i) => builderLetters[i]).join();
    if (answer == 'STUPA') {
      await _completeStage();
    } else {
      setState(() => feedback = 'Not quite — undo a letter and try again.');
    }
  }

  void _undoBuilder() {
    if (transitioning || builderSelection.isEmpty) return;
    setState(() {
      builderSelection.removeLast();
      feedback = null;
    });
  }

  Future<void> _chooseMeaning(int index) async {
    if (transitioning) return;
    setState(() {
      meaningSelection = index;
      feedback = index == 0 ? null : 'That is not it — try another answer.';
    });
    if (index == 0) await _completeStage();
  }

  Future<void> _addFillLetter(int index) async {
    if (transitioning || fillSelection.contains(index)) return;
    setState(() {
      fillSelection.add(index);
      feedback = null;
    });
    if (fillSelection.length != 3) return;
    final answer = fillSelection.map((i) => fillLetters[i]).join();
    if (answer == 'GRY') {
      await _completeStage();
    } else {
      setState(() => feedback = 'Check the spelling and undo the last letter.');
    }
  }

  void _undoFill() {
    if (transitioning || fillSelection.isEmpty) return;
    setState(() {
      fillSelection.removeLast();
      feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _quizBackground,
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: null,
      onSelected: _navigate,
    ),
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              _QuizProgressHeader(
                stage: stage,
                onClose: () => Navigator.maybePop(context),
              ),
              const Divider(height: 1, color: _quizLine),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(23, 17, 23, 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (stage) {
                      0 => _buildWordBuilder(),
                      1 => _buildMeaningMatch(),
                      _ => _buildFillLetters(),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildWordBuilder() => Column(
    key: const ValueKey('word-builder-stage'),
    children: [
      const _Clue(text: 'Dome-shaped monument enshrining a relic'),
      const SizedBox(height: 24),
      DragTarget<int>(
        key: const Key('word-builder-drop-zone'),
        onWillAcceptWithDetails: (details) =>
            !builderSelection.contains(details.data),
        onAcceptWithDetails: (details) => _addBuilderLetter(details.data),
        builder: (context, candidates, rejected) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: candidates.isEmpty ? Colors.transparent : _quizPeach,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            children: [
              for (var i = 0; i < builderLetters.length; i++)
                _LetterSlot(
                  letter: i < builderSelection.length
                      ? builderLetters[builderSelection[i]]
                      : null,
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 29),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < builderLetters.length; i++)
            _DraggableLetter(
              key: Key('builder-letter-${builderLetters[i]}'),
              index: i,
              letter: builderLetters[i],
              used: builderSelection.contains(i),
              onTap: () => _addBuilderLetter(i),
            ),
        ],
      ),
      const SizedBox(height: 25),
      _UndoButton(
        key: const Key('builder-undo'),
        enabled: builderSelection.isNotEmpty && !transitioning,
        onPressed: _undoBuilder,
      ),
      _Feedback(message: feedback),
    ],
  );

  Widget _buildMeaningMatch() {
    const options = [
      'A dome-shaped relic monument',
      'A monastery kitchen',
      'A royal bathing pool',
      'A carved gateway stone',
    ];
    return Column(
      key: const ValueKey('meaning-match-stage'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          decoration: BoxDecoration(
            color: _quizSurface,
            border: Border.all(color: _quizLine),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text(
                'WHAT DOES THIS MEAN?',
                style: TextStyle(
                  color: _quizMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              SizedBox(height: 52),
              Text(
                'dāgaba',
                style: TextStyle(
                  color: AppColors.brown,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < options.length; i++) ...[
          _MeaningOption(
            key: Key('meaning-option-$i'),
            letter: String.fromCharCode(65 + i),
            text: options[i],
            selected: meaningSelection == i,
            isWrong: meaningSelection == i && i != 0,
            onTap: () => _chooseMeaning(i),
          ),
          if (i != options.length - 1) const SizedBox(height: 10),
        ],
        _Feedback(message: feedback),
      ],
    );
  }

  Widget _buildFillLetters() {
    const target = 'SIGIRIYA';
    const blankPositions = [2, 4, 6];
    return Column(
      key: const ValueKey('fill-letters-stage'),
      children: [
        const _Clue(text: 'The rock fortress with the lion’s paws'),
        const SizedBox(height: 24),
        DragTarget<int>(
          key: const Key('fill-letters-drop-zone'),
          onWillAcceptWithDetails: (details) =>
              !fillSelection.contains(details.data),
          onAcceptWithDetails: (details) => _addFillLetter(details.data),
          builder: (context, candidates, rejected) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: candidates.isEmpty ? Colors.transparent : _quizPeach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 7,
              children: [
                for (var position = 0; position < target.length; position++)
                  _LetterSlot(
                    dashed: false,
                    letter: blankPositions.contains(position)
                        ? _fillLetterForPosition(
                            blankPositions.indexOf(position),
                          )
                        : target[position],
                    muted: !blankPositions.contains(position),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            for (var i = 0; i < fillLetters.length; i++)
              _DraggableLetter(
                key: Key('fill-letter-${fillLetters[i]}-$i'),
                index: i,
                letter: fillLetters[i],
                used: fillSelection.contains(i),
                onTap: () => _addFillLetter(i),
                compact: true,
              ),
          ],
        ),
        const SizedBox(height: 25),
        _UndoButton(
          key: const Key('fill-undo'),
          enabled: fillSelection.isNotEmpty && !transitioning,
          onPressed: _undoFill,
        ),
        _Feedback(message: feedback),
      ],
    );
  }

  String? _fillLetterForPosition(int blankIndex) {
    if (blankIndex >= fillSelection.length) return null;
    return fillLetters[fillSelection[blankIndex]];
  }
}

class _QuizProgressHeader extends StatelessWidget {
  const _QuizProgressHeader({required this.stage, required this.onClose});
  final int stage;
  final VoidCallback onClose;

  static const titles = ['WORD BUILDER', 'MEANING MATCH', 'FILL THE LETTERS'];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('close-daily-quiz'),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 31, height: 36),
              icon: const Icon(Icons.close, color: Color(0xFF33231D)),
            ),
            const SizedBox(width: 11),
            for (var i = 0; i < 3; i++) ...[
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: i < stage
                        ? AppColors.brown
                        : const Color(0xFFEDE2D2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              if (i != 2) const SizedBox(width: 11),
            ],
            const SizedBox(width: 11),
            SizedBox(
              width: 26,
              child: Text(
                '$stage/3',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: _quizMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              titles[stage],
              style: const TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Clue extends StatelessWidget {
  const _Clue({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    decoration: BoxDecoration(
      color: _quizPeach,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        const Icon(Icons.lightbulb_outline, color: AppColors.brown, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(0xFF693528))),
        ),
      ],
    ),
  );
}

class _LetterSlot extends StatelessWidget {
  const _LetterSlot({
    required this.letter,
    this.dashed = true,
    this.muted = false,
  });
  final String? letter;
  final bool dashed;
  final bool muted;

  @override
  Widget build(BuildContext context) => Container(
    width: 43,
    height: 55,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: muted ? const Color(0xFFF6F0E8) : _quizSurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: letter == null || dashed ? _quizLine : Colors.transparent,
        width: letter == null ? 2 : 1,
      ),
    ),
    child: Text(
      letter ?? '',
      style: TextStyle(
        color: muted ? _quizMuted : const Color(0xFF3A2821),
        fontFamily: 'Georgia',
        fontSize: 21,
      ),
    ),
  );
}

class _DraggableLetter extends StatelessWidget {
  const _DraggableLetter({
    super.key,
    required this.index,
    required this.letter,
    required this.used,
    required this.onTap,
    this.compact = false,
  });
  final int index;
  final String letter;
  final bool used;
  final VoidCallback onTap;
  final bool compact;

  Widget tile({double opacity = 1}) => Opacity(
    opacity: opacity,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: used ? null : onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: compact ? 47 : 55,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _quizSurface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _quizLine),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            letter,
            style: const TextStyle(
              color: Color(0xFF392720),
              fontFamily: 'Georgia',
              fontSize: 21,
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (used) return tile(opacity: .28);
    return LongPressDraggable<int>(
      data: index,
      feedback: tile(opacity: .92),
      childWhenDragging: tile(opacity: .2),
      child: tile(),
    );
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: enabled ? onPressed : null,
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.brown,
      side: const BorderSide(color: _quizLine),
      shape: const StadiumBorder(),
    ),
    icon: const Icon(Icons.backspace_outlined, size: 15),
    label: const Text('Undo letter'),
  );
}

class _MeaningOption extends StatelessWidget {
  const _MeaningOption({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.isWrong,
    required this.onTap,
  });
  final String letter;
  final String text;
  final bool selected;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? isWrong
              ? const Color(0xFFFFECE7)
              : _quizPeach
        : _quizSurface,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isWrong ? const Color(0xFFD47761) : _quizLine,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFFF0E5D5),
              child: Text(
                letter,
                style: const TextStyle(
                  color: _quizMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    ),
  );
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 150),
    child: message == null
        ? const SizedBox(key: ValueKey('no-feedback'), height: 14)
        : Padding(
            key: ValueKey(message),
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: message == 'Correct!'
                    ? const Color(0xFF34713D)
                    : AppColors.brown,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
  );
}
