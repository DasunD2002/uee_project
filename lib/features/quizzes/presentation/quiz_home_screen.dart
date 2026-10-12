import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../data/quiz_service.dart';
import '../domain/quiz.dart';
import 'daily_quiz_screen.dart';

const _pageBackground = Colors.white;
const _cardBackground = Color(0xFFFFFCF8);
const _softPeach = Color(0xFFFFEBD8);
const _lineColor = Color(0xFFEBDACB);
const _mutedText = Color(0xFF8C766B);

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key, this.quizService});

  final QuizService? quizService;

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  late final QuizService _quizService;
  QuizDashboard? _dashboard;
  bool _loading = true;
  bool _starting = false;
  String? _error;

  static const challenges = <({String title, String subtitle, int points})>[
    (
      title: 'Word Builder',
      subtitle: 'Make the word from scattered letters',
      points: 40,
    ),
    (
      title: 'Meaning Match',
      subtitle: 'Pick what the heritage word means',
      points: 30,
    ),
    (
      title: 'Fill the Letters',
      subtitle: 'Complete the missing letters',
      points: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _quizService = widget.quizService ?? ApiQuizService();
    _loadDashboard();
  }

  Future<void> _play() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final session = await _quizService.startOrResume();
      if (!mounted) return;
      final result = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) => DailyQuizScreen(
            quizService: _quizService,
            initialSession: session,
          ),
        ),
      );
      if (!mounted) return;
      await _loadDashboard();
      if (!mounted || result == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily challenge complete — $result XP earned!'),
          backgroundColor: AppColors.brown,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dashboard = await _quizService.getDashboard();
      if (mounted) setState(() => _dashboard = dashboard);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigate(int index) => navigateToPrimaryDestination(context, index);

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;
    if (_loading && dashboard == null) {
      return const Scaffold(
        backgroundColor: _pageBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (dashboard == null) {
      return Scaffold(
        backgroundColor: _pageBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error ?? 'The quiz dashboard could not be loaded.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loadDashboard,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final completed = dashboard.completedSteps;
    final next = completed < challenges.length ? challenges[completed] : null;

    return Scaffold(
      backgroundColor: _pageBackground,
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: null,
        onSelected: _navigate,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(23, 28, 23, 34),
              children: [
                const _PageHeading(),
                const SizedBox(height: 18),
                _StreakCard(
                  streakDays: dashboard.streakDays,
                  activity: dashboard.weekActivity,
                ),
                const SizedBox(height: 23),
                _SetProgress(completed: completed, score: dashboard.todayScore),
                const SizedBox(height: 10),
                if (next != null)
                  _UpNextCard(
                    title: next.title,
                    subtitle: next.subtitle,
                    points: next.points,
                    isResume: dashboard.activeSessionId != null,
                    onPlay: _starting ? null : _play,
                  )
                else
                  _CompletedCard(
                    score: dashboard.todayScore,
                    onReplay: _starting ? null : _play,
                  ),
                const SizedBox(height: 12),
                for (var i = 0; i < challenges.length; i++)
                  if (next == null || i != completed) ...[
                    _ChallengeRow(
                      index: i,
                      title: challenges[i].title,
                      subtitle: challenges[i].subtitle,
                      completed: i < completed,
                      locked: i > completed,
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 13),
                _Leaderboard(leaders: dashboard.weeklyLeaders),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: Text(
          'Daily challenge',
          style: TextStyle(
            color: Color(0xFF34231D),
            fontFamily: 'Georgia',
            fontSize: 22,
          ),
        ),
      ),
      Icon(Icons.emoji_events_outlined, color: Color(0xFF34231D), size: 23),
    ],
  );
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streakDays, required this.activity});

  final int streakDays;
  final List<bool> activity;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
    decoration: BoxDecoration(
      color: AppColors.brown,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF9C432D),
              child: Icon(
                Icons.local_fire_department_outlined,
                color: Color(0xFFFFC19D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streakDays day streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Georgia',
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Three challenges a day keeps it alive',
                    style: TextStyle(color: Color(0xFFFFD9C6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var index = 0; index < 7; index++)
              _DayDot(
                label: index < activity.length && activity[index]
                    ? '✓'
                    : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                completed: index < activity.length && activity[index],
                today: index == DateTime.now().weekday - 1,
              ),
          ],
        ),
      ],
    ),
  );
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.completed,
    required this.today,
  });
  final String label;
  final bool completed;
  final bool today;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: completed ? const Color(0xFFFFE7CC) : Colors.transparent,
      border: Border.all(
        color: today ? const Color(0xFFFFE7CC) : const Color(0xFFAA5A43),
        width: today ? 2 : 1,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: completed ? AppColors.brown : const Color(0xFFE4AA91),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
}

class _SetProgress extends StatelessWidget {
  const _SetProgress({required this.completed, required this.score});
  final int completed;
  final int score;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              "Today's set",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 19,
                color: Color(0xFF3C2922),
              ),
            ),
          ),
          Text(
            '$completed of 3 · $score/100 XP',
            style: const TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          minHeight: 5,
          value: score / 100,
          color: AppColors.brown,
          backgroundColor: const Color(0xFFF1E5D6),
        ),
      ),
    ],
  );
}

class _UpNextCard extends StatelessWidget {
  const _UpNextCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.isResume,
    required this.onPlay,
  });
  final String title;
  final String subtitle;
  final int points;
  final bool isResume;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBackground,
      border: Border.all(color: _lineColor),
      borderRadius: BorderRadius.circular(17),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 7,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UP NEXT',
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 23,
            color: Color(0xFF34231D),
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: _mutedText, fontSize: 13)),
        const SizedBox(height: 14),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton(
              key: const Key('play-daily-quiz'),
              onPressed: onPlay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 19),
              ),
              child: Text(isResume ? 'Resume' : 'Play now'),
            ),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 16, color: _mutedText),
                SizedBox(width: 4),
                Text('90 sec', style: TextStyle(color: _mutedText)),
              ],
            ),
            Text('+$points XP', style: const TextStyle(color: AppColors.brown)),
          ],
        ),
      ],
    ),
  );
}

class _CompletedCard extends StatelessWidget {
  const _CompletedCard({required this.score, required this.onReplay});
  final int score;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('quiz-completed-card'),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: _softPeach,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFF1D0B4)),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          child: Icon(Icons.emoji_events_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily set complete!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text('$score XP earned today'),
            ],
          ),
        ),
        TextButton(onPressed: onReplay, child: const Text('Replay')),
      ],
    ),
  );
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.locked,
  });
  final int index;
  final String title;
  final String subtitle;
  final bool completed;
  final bool locked;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: _cardBackground,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: _lineColor),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _softPeach,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            index == 0
                ? Icons.text_fields
                : index == 1
                ? Icons.hub_outlined
                : Icons.spellcheck,
            color: AppColors.brown,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
        if (completed) ...[
          const Icon(
            Icons.check_circle_outline,
            size: 17,
            color: AppColors.brown,
          ),
          const SizedBox(width: 4),
          const Text(
            'Done',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ] else
          Icon(
            locked ? Icons.lock_outline : Icons.chevron_right,
            color: _mutedText,
            size: 19,
          ),
      ],
    ),
  );
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.leaders});

  final List<QuizLeader> leaders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Weekly leaders',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 19,
                  color: Color(0xFF3C2922),
                ),
              ),
            ),
            Text(
              'Resets Sunday',
              style: TextStyle(color: _mutedText, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _lineColor),
          ),
          child: Column(
            children: [
              if (leaders.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Complete a challenge to join this week’s leaderboard.',
                    style: TextStyle(color: _mutedText, fontSize: 12),
                  ),
                ),
              for (var i = 0; i < leaders.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: _lineColor),
                Container(
                  color: leaders[i].viewer ? _softPeach : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 28, child: Text('${leaders[i].rank}')),
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: const Color(0xFFFFE1C6),
                        child: Text(
                          leaders[i].initials,
                          style: const TextStyle(
                            color: AppColors.brown,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: leaders[i].name,
                            children: leaders[i].viewer
                                ? const [
                                    TextSpan(
                                      text: '  You',
                                      style: TextStyle(
                                        color: AppColors.brown,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                      Text(
                        '${leaders[i].score} XP',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
