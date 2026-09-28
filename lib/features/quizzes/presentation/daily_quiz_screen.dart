import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../data/quiz_service.dart';
import '../domain/quiz.dart';

const _quizBackground = Colors.white;
const _quizSurface = Color(0xFFFFFCF8);
const _quizPeach = Color(0xFFFFEBD8);
const _quizLine = Color(0xFFEBDACB);
const _quizMuted = Color(0xFF8C766B);

enum _FeedbackTone { success, warning, error }

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key, this.quizService, this.initialSession});

  final QuizService? quizService;
  final QuizSession? initialSession;

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  late final QuizService _quizService;
  QuizSession? _session;
  Timer? _timer;
  int _remainingSeconds = 30;
  List<int?> _builderSlots = [];
  List<int?> _fillSlots = [];
  final List<int> _builderPlacementOrder = [];
  final List<int> _fillPlacementOrder = [];
  int? meaningSelection;
  String? feedback;
  _FeedbackTone? _feedbackTone;
  bool _loading = true;
  bool _submitting = false;
  bool _handlingTimeout = false;

  @override
  void initState() {
    super.initState();
    _quizService = widget.quizService ?? ApiQuizService();
    final initial = widget.initialSession;
    if (initial == null) {
      _loadSession();
    } else {
      _applySession(initial);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigate(int index) => navigateToPrimaryDestination(context, index);

  Future<void> _loadSession() async {
    try {
      final session = await _quizService.startOrResume();
      if (mounted) _applySession(session);
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          feedback = error.toString();
          _feedbackTone = _FeedbackTone.error;
        });
      }
    }
  }

  void _applySession(QuizSession session) {
    _timer?.cancel();
    final question = session.question;
    setState(() {
      _session = session;
      _loading = false;
      _submitting = false;
      _handlingTimeout = false;
      meaningSelection = null;
      feedback = null;
      _feedbackTone = null;
      _builderSlots = List<int?>.filled(question?.targetLength ?? 0, null);
      _fillSlots = List<int?>.filled(
        question?.blankPositions.length ?? 0,
        null,
      );
      _builderPlacementOrder.clear();
      _fillPlacementOrder.clear();
    });
    if (question != null) _startTimer(question.deadlineAt);
  }

  void _startTimer(DateTime deadline) {
    void update() {
      if (!mounted) return;
      final milliseconds = deadline
          .difference(DateTime.now().toUtc())
          .inMilliseconds;
      final remaining = milliseconds <= 0 ? 0 : (milliseconds / 1000).ceil();
      if (remaining != _remainingSeconds) {
        setState(() => _remainingSeconds = remaining);
      }
      if (remaining == 0 && !_handlingTimeout && !_submitting) {
        _handlingTimeout = true;
        unawaited(_submitAnswer(null));
      }
    }

    update();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => update());
  }

  Future<void> _submitAnswer(String? answer) async {
    final session = _session;
    final question = session?.question;
    if (_submitting || session == null || question == null) return;
    setState(() => _submitting = true);
    try {
      final result = await _quizService.submitAnswer(
        sessionId: session.id,
        questionId: question.id,
        answer: answer,
        timedOut: answer == null,
      );
      if (!mounted) return;
      setState(() {
        feedback = result.feedback;
        _feedbackTone = result.correct
            ? _FeedbackTone.success
            : _FeedbackTone.warning;
      });
      if (!result.correct && !result.timedOut) {
        setState(() => _submitting = false);
        return;
      }
      _timer?.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      if (result.completed) {
        Navigator.pop(context, result.session.totalScore);
      } else {
        _applySession(result.session);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          feedback = error.toString();
          _feedbackTone = _FeedbackTone.error;
          _submitting = false;
          _handlingTimeout = false;
        });
      }
    }
  }

  void _placeBuilderLetter(int slot, int letterIndex) {
    if (_submitting || slot < 0 || slot >= _builderSlots.length) return;
    setState(() {
      final previousSlot = _builderSlots.indexOf(letterIndex);
      if (previousSlot >= 0) _builderSlots[previousSlot] = null;
      _builderSlots[slot] = letterIndex;
      _builderPlacementOrder
        ..remove(slot)
        ..add(slot);
      feedback = null;
      _feedbackTone = null;
    });
    if (_builderSlots.every((value) => value != null)) {
      final letters = _session!.question!.letters;
      _submitAnswer(_builderSlots.map((index) => letters[index!]).join());
    }
  }

  void _addBuilderLetter(int index) {
    final slot = _builderSlots.indexOf(null);
    if (slot >= 0) _placeBuilderLetter(slot, index);
  }

  void _removeBuilderSlot(int slot) {
    if (_submitting || _builderSlots[slot] == null) return;
    setState(() {
      _builderSlots[slot] = null;
      _builderPlacementOrder.remove(slot);
      feedback = null;
      _feedbackTone = null;
    });
  }

  void _undoBuilder() {
    if (_submitting || _builderPlacementOrder.isEmpty) return;
    _removeBuilderSlot(_builderPlacementOrder.last);
  }

  void _chooseMeaning(int index) {
    final question = _session?.question;
    if (_submitting || question == null) return;
    setState(() {
      meaningSelection = index;
      feedback = null;
      _feedbackTone = null;
    });
    _submitAnswer(question.options[index]);
  }

  void _placeFillLetter(int slot, int letterIndex) {
    if (_submitting || slot < 0 || slot >= _fillSlots.length) return;
    setState(() {
      final previousSlot = _fillSlots.indexOf(letterIndex);
      if (previousSlot >= 0) _fillSlots[previousSlot] = null;
      _fillSlots[slot] = letterIndex;
      _fillPlacementOrder
        ..remove(slot)
        ..add(slot);
      feedback = null;
      _feedbackTone = null;
    });
    if (_fillSlots.every((value) => value != null)) {
      final letters = _session!.question!.letters;
      _submitAnswer(_fillSlots.map((index) => letters[index!]).join());
    }
  }

  void _addFillLetter(int index) {
    final slot = _fillSlots.indexOf(null);
    if (slot >= 0) _placeFillLetter(slot, index);
  }

  void _removeFillSlot(int slot) {
    if (_submitting || _fillSlots[slot] == null) return;
    setState(() {
      _fillSlots[slot] = null;
      _fillPlacementOrder.remove(slot);
      feedback = null;
      _feedbackTone = null;
    });
  }

  void _undoFill() {
    if (_submitting || _fillPlacementOrder.isEmpty) return;
    _removeFillSlot(_fillPlacementOrder.last);
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final question = session?.question;
    return Scaffold(
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : question == null
                ? _QuizLoadError(message: feedback, onRetry: _loadSession)
                : Column(
                    children: [
                      _QuizProgressHeader(
                        stage: session!.currentStage,
                        remainingSeconds: _remainingSeconds,
                        score: session.totalScore,
                        onClose: () => Navigator.maybePop(context),
                      ),
                      const Divider(height: 1, color: _quizLine),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(23, 17, 23, 32),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: switch (question.type) {
                              QuizType.wordBuilder => _buildWordBuilder(
                                question,
                              ),
                              QuizType.meaningMatch => _buildMeaningMatch(
                                question,
                              ),
                              QuizType.fillLetters => _buildFillLetters(
                                question,
                              ),
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
  }

  Widget _buildWordBuilder(QuizQuestion question) => Column(
    key: const ValueKey('word-builder-stage'),
    children: [
      _Clue(text: question.prompt),
      const SizedBox(height: 24),
      Wrap(
        key: const Key('word-builder-drop-zone'),
        alignment: WrapAlignment.center,
        spacing: 7,
        runSpacing: 7,
        children: [
          for (var slot = 0; slot < _builderSlots.length; slot++)
            _LetterDropSlot(
              key: Key('builder-slot-$slot'),
              letter: _builderSlots[slot] == null
                  ? null
                  : question.letters[_builderSlots[slot]!],
              enabled: !_submitting,
              onAccept: (letterIndex) => _placeBuilderLetter(slot, letterIndex),
              onClear: () => _removeBuilderSlot(slot),
            ),
        ],
      ),
      const SizedBox(height: 29),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < question.letters.length; i++)
            _DraggableLetter(
              key: Key('builder-letter-${question.letters[i]}-$i'),
              index: i,
              letter: question.letters[i],
              used: _builderSlots.contains(i),
              onTap: () => _addBuilderLetter(i),
            ),
        ],
      ),
      const SizedBox(height: 25),
      _UndoButton(
        key: const Key('builder-undo'),
        enabled: _builderSlots.any((value) => value != null) && !_submitting,
        onPressed: _undoBuilder,
      ),
      _Feedback(message: feedback, tone: _feedbackTone),
    ],
  );

  Widget _buildMeaningMatch(QuizQuestion question) {
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
          child: Column(
            children: [
              const Text(
                'WHAT DOES THIS MEAN?',
                style: TextStyle(
                  color: _quizMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 52),
              Text(
                question.displayWord,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < question.options.length; i++) ...[
          _MeaningOption(
            key: Key('meaning-option-$i'),
            letter: String.fromCharCode(65 + i),
            text: question.options[i],
            selected: meaningSelection == i,
            isWrong:
                meaningSelection == i &&
                feedback != null &&
                _feedbackTone == _FeedbackTone.warning,
            onTap: () => _chooseMeaning(i),
          ),
          if (i != question.options.length - 1) const SizedBox(height: 10),
        ],
        _Feedback(message: feedback, tone: _feedbackTone),
      ],
    );
  }

  Widget _buildFillLetters(QuizQuestion question) {
    final characters = question.displayWord.characters.toList();
    return Column(
      key: const ValueKey('fill-letters-stage'),
      children: [
        _Clue(text: question.prompt),
        const SizedBox(height: 24),
        Wrap(
          key: const Key('fill-letters-drop-zone'),
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 7,
          children: [
            for (var position = 0; position < characters.length; position++)
              if (question.blankPositions.contains(position))
                _LetterDropSlot(
                  key: Key('fill-slot-$position'),
                  letter:
                      _fillSlots[question.blankPositions.indexOf(position)] ==
                          null
                      ? null
                      : question.letters[_fillSlots[question.blankPositions
                            .indexOf(position)]!],
                  enabled: !_submitting,
                  dashed: false,
                  onAccept: (letterIndex) => _placeFillLetter(
                    question.blankPositions.indexOf(position),
                    letterIndex,
                  ),
                  onClear: () => _removeFillSlot(
                    question.blankPositions.indexOf(position),
                  ),
                )
              else
                _LetterSlot(
                  dashed: false,
                  letter: characters[position],
                  muted: true,
                ),
          ],
        ),
        const SizedBox(height: 25),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            for (var i = 0; i < question.letters.length; i++)
              _DraggableLetter(
                key: Key('fill-letter-${question.letters[i]}-$i'),
                index: i,
                letter: question.letters[i],
                used: _fillSlots.contains(i),
                onTap: () => _addFillLetter(i),
                compact: true,
              ),
          ],
        ),
        const SizedBox(height: 25),
        _UndoButton(
          key: const Key('fill-undo'),
          enabled: _fillSlots.any((value) => value != null) && !_submitting,
          onPressed: _undoFill,
        ),
        _Feedback(message: feedback, tone: _feedbackTone),
      ],
    );
  }
}

class _QuizLoadError extends StatelessWidget {
  const _QuizLoadError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? 'The quiz could not be loaded.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _QuizProgressHeader extends StatelessWidget {
  const _QuizProgressHeader({
    required this.stage,
    required this.remainingSeconds,
    required this.score,
    required this.onClose,
  });
  final int stage;
  final int remainingSeconds;
  final int score;
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
            Container(
              key: const Key('quiz-countdown'),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: remainingSeconds <= 5
                    ? const Color(0xFFFFE1D9)
                    : _quizPeach,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${remainingSeconds}s',
                    style: TextStyle(
                      color: remainingSeconds <= 5
                          ? const Color(0xFFB23A24)
                          : AppColors.brown,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    titles[stage.clamp(0, 2)],
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Text(
                  '$stage/3 · $score XP',
                  style: const TextStyle(color: _quizMuted, fontSize: 11),
                ),
              ],
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

class _LetterDropSlot extends StatelessWidget {
  const _LetterDropSlot({
    super.key,
    required this.letter,
    required this.enabled,
    required this.onAccept,
    required this.onClear,
    this.dashed = true,
  });

  final String? letter;
  final bool enabled;
  final ValueChanged<int> onAccept;
  final VoidCallback onClear;
  final bool dashed;

  @override
  Widget build(BuildContext context) => DragTarget<int>(
    onWillAcceptWithDetails: (_) => enabled,
    onAcceptWithDetails: (details) => onAccept(details.data),
    builder: (context, candidates, rejected) => AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: candidates.isEmpty ? Colors.transparent : _quizPeach,
        borderRadius: BorderRadius.circular(13),
        border: candidates.isEmpty
            ? null
            : Border.all(color: AppColors.brown, width: 1.5),
      ),
      child: GestureDetector(
        onTap: letter == null || !enabled ? null : onClear,
        child: _LetterSlot(letter: letter, dashed: dashed),
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
  const _Feedback({required this.message, required this.tone});
  final String? message;
  final _FeedbackTone? tone;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 150),
    child: message == null
        ? const SizedBox(key: ValueKey('no-feedback'), height: 14)
        : Container(
            key: Key('quiz-feedback-${tone?.name ?? 'warning'}'),
            width: double.infinity,
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: switch (tone) {
                _FeedbackTone.success => const Color(0xFFE6F5E9),
                _FeedbackTone.error => const Color(0xFFFFE9E5),
                _ => const Color(0xFFFFF1DE),
              },
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: switch (tone) {
                  _FeedbackTone.success => const Color(0xFF9CCDA5),
                  _FeedbackTone.error => const Color(0xFFE7A69A),
                  _ => const Color(0xFFE7C794),
                },
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  switch (tone) {
                    _FeedbackTone.success => Icons.check_circle_outline,
                    _FeedbackTone.error => Icons.error_outline,
                    _ => Icons.refresh,
                  },
                  size: 18,
                  color: switch (tone) {
                    _FeedbackTone.success => const Color(0xFF34713D),
                    _FeedbackTone.error => const Color(0xFFB34735),
                    _ => AppColors.brown,
                  },
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: switch (tone) {
                        _FeedbackTone.success => const Color(0xFF34713D),
                        _FeedbackTone.error => const Color(0xFFB34735),
                        _ => AppColors.brown,
                      },
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}
