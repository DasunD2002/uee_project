import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../explorer/presentation/widgets/explorer_footer.dart';

// ── Palette — matches the rest of the app ────────────────────────────────────
const _kBg       = Color(0xFFFDF8F5);   // warm off-white page background
const _kCard     = Color(0xFFFFFFFF);   // card surface
const _kBrown    = Color(0xFF84321F);   // primary brown (AppColors.brown)
const _kBrownDp  = Color(0xFF5A1E0E);   // deep headings
const _kTerra    = Color(0xFFB85C3A);   // terracotta accent
const _kGold     = Color(0xFFD4A24C);   // gold accent
const _kBorder   = Color(0xFFEEDFD9);   // card border
const _kMuted    = Color(0xFFA07060);   // secondary text
const _kPeach    = Color(0xFFFFF3E8);   // button background tint
const _kPeachBd  = Color(0xFFD9B49E);   // button border
const _kRose     = Color(0xFFE8B4A8);   // light rose
const _kRoseMid  = Color(0xFFF5DDD8);   // soft rose

/// "Add a Memory" screen – warm earthy theme consistent with the rest of the app.
class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen>
    with TickerProviderStateMixin {
  int _step = 0;          // 0 pick type · 1 add content · 2 review & seal
  _MemoryType? _picked;

  late final AnimationController _stepCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  final _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _stepCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _finish() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kBrownDp,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        content: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.white, size: 17),
            SizedBox(width: 10),
            Text('Sealed into your capsule ✦',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: _kBrown,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: _step == 0 ? 'Back' : 'Previous step',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (_step == 0) {
              Navigator.pop(context);
            } else {
              setState(() => _step--);
            }
          },
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Column(
            key: ValueKey(_step),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _stepTitle(_step),
                style: const TextStyle(
                  color: _kBrownDp,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _stepSub(_step),
                style:
                    const TextStyle(color: _kMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          // Gold step counter pill
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0D6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8C68A)),
            ),
            child: Text(
              '${_step + 1} / 3',
              style: const TextStyle(
                color: _kGold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Step progress bar ──────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      height: 3,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: active ? _kBrown : _kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Main content ───────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: switch (_step) {
                  0 => _StepPickType(
                      key: const ValueKey(0),
                      picked: _picked,
                      onPick: (t) => setState(() => _picked = t),
                    ),
                  1 => _StepContent(
                      key: const ValueKey(1),
                      type: _picked!,
                      captionCtrl: _captionCtrl,
                    ),
                  _ => _StepReview(
                      key: const ValueKey(2),
                      type: _picked!,
                      caption: _captionCtrl.text,
                    ),
                },
              ),
            ),

            // ── Bottom CTA ────────────────────────────────────────────────
            _BottomCTA(
              step: _step,
              enabled: _step == 0 ? _picked != null : true,
              onPressed: _advance,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 3,
        onSelected: (_) {},
      ),
    );
  }

  static String _stepTitle(int s) =>
      ['Choose Memory', 'Add Content', 'Review & Seal'][s];
  static String _stepSub(int s) => [
        'What do you want to preserve?',
        'Upload or create your memory',
        'Caption & seal the moment',
      ][s];
}

// ── Step 1: Choose memory type ────────────────────────────────────────────────

class _StepPickType extends StatelessWidget {
  const _StepPickType({
    super.key,
    required this.picked,
    required this.onPick,
  });
  final _MemoryType? picked;
  final ValueChanged<_MemoryType> onPick;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Featured hero card (Photo) ──────────────────────────────────
          _HeroTypeCard(
            type: _MemoryType.photo,
            selected: picked == _MemoryType.photo,
            onTap: () => onPick(_MemoryType.photo),
          ),
          const SizedBox(height: 12),

          // ── Three smaller cards ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SmallTypeCard(
                  type: _MemoryType.video,
                  selected: picked == _MemoryType.video,
                  onTap: () => onPick(_MemoryType.video),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallTypeCard(
                  type: _MemoryType.voiceNote,
                  selected: picked == _MemoryType.voiceNote,
                  onTap: () => onPick(_MemoryType.voiceNote),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallTypeCard(
                  type: _MemoryType.letter,
                  selected: picked == _MemoryType.letter,
                  onTap: () => onPick(_MemoryType.letter),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Info strip ──────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7EE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8C68A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: _kGold, size: 15),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sealed until April 14, 2027',
                        style: TextStyle(
                          color: _kBrownDp,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Only family contributors will see this',
                        style: TextStyle(color: _kMuted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero type card ────────────────────────────────────────────────────────────

class _HeroTypeCard extends StatefulWidget {
  const _HeroTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final _MemoryType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_HeroTypeCard> createState() => _HeroTypeCardState();
}

class _HeroTypeCardState extends State<_HeroTypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
    lowerBound: 0,
    upperBound: .015,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    final sel = widget.selected;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: 1 - _ctrl.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 148,
          decoration: BoxDecoration(
            color: sel ? t.lightBg : _kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? t.accent.withAlpha(180) : _kBorder,
              width: sel ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? t.accent.withAlpha(35)
                    : const Color(0x0F000000),
                blurRadius: sel ? 18 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ghost background icon
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  t.icon,
                  size: 100,
                  color: t.accent.withAlpha(sel ? 22 : 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: sel
                            ? t.accent.withAlpha(35)
                            : const Color(0xFFF5EDE8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(t.icon,
                          color: t.accent, size: 22),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.label,
                              style: TextStyle(
                                color: _kBrownDp,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.4,
                              ),
                            ),
                            Text(
                              t.sublabel,
                              style: const TextStyle(
                                  color: _kMuted, fontSize: 11.5),
                            ),
                          ],
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color:
                                sel ? t.accent : const Color(0xFFF0E4DF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sel
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color:
                                sel ? Colors.white : _kMuted,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small type card ───────────────────────────────────────────────────────────

class _SmallTypeCard extends StatefulWidget {
  const _SmallTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final _MemoryType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SmallTypeCard> createState() => _SmallTypeCardState();
}

class _SmallTypeCardState extends State<_SmallTypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
    lowerBound: 0,
    upperBound: .02,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    final sel = widget.selected;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: 1 - _ctrl.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 96,
          decoration: BoxDecoration(
            color: sel ? t.lightBg : _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? t.accent.withAlpha(160) : _kBorder,
              width: sel ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? t.accent.withAlpha(28)
                    : const Color(0x0A000000),
                blurRadius: sel ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sel
                      ? t.accent.withAlpha(30)
                      : const Color(0xFFF5EDE8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(t.icon, size: 18, color: t.accent),
              ),
              const SizedBox(height: 8),
              Text(
                t.label,
                style: TextStyle(
                  color: _kBrownDp,
                  fontSize: 11,
                  fontWeight:
                      sel ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 2: Add content ───────────────────────────────────────────────────────

class _StepContent extends StatefulWidget {
  const _StepContent({
    super.key,
    required this.type,
    required this.captionCtrl,
  });
  final _MemoryType type;
  final TextEditingController captionCtrl;

  @override
  State<_StepContent> createState() => _StepContentState();
}

class _StepContentState extends State<_StepContent>
    with TickerProviderStateMixin {
  bool _hasContent = false;
  bool _recording = false;

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Type badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: t.lightBg,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: t.accent.withAlpha(100)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 13, color: t.accent),
                  const SizedBox(width: 6),
                  Text(t.label,
                      style: TextStyle(
                        color: t.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content area
          if (t == _MemoryType.voiceNote)
            _VoiceRecorder(
              recording: _recording,
              hasContent: _hasContent,
              pulseCtrl: _pulseCtrl,
              accent: t.accent,
              onToggle: () {
                setState(() => _recording = !_recording);
                if (_recording) {
                  _pulseCtrl.repeat(reverse: true);
                } else {
                  _pulseCtrl.stop();
                  setState(() => _hasContent = true);
                }
              },
            )
          else if (t == _MemoryType.letter)
            const _LetterEditor()
          else
            _MediaUploader(
              type: t,
              hasContent: _hasContent,
              onUploaded: () => setState(() => _hasContent = true),
            ),

          const SizedBox(height: 18),
          _CaptionInput(controller: widget.captionCtrl),
        ],
      ),
    );
  }
}

// ── Voice recorder ────────────────────────────────────────────────────────────

class _VoiceRecorder extends StatefulWidget {
  const _VoiceRecorder({
    required this.recording,
    required this.hasContent,
    required this.pulseCtrl,
    required this.accent,
    required this.onToggle,
  });
  final bool recording;
  final bool hasContent;
  final AnimationController pulseCtrl;
  final Color accent;
  final VoidCallback onToggle;

  @override
  State<_VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<_VoiceRecorder>
    with TickerProviderStateMixin {
  late final List<AnimationController> _waveCtrls = List.generate(
    14,
    (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 280 + i * 50),
    )..repeat(reverse: true),
  );

  @override
  void dispose() {
    for (final c in _waveCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Waveform
          if (widget.recording || widget.hasContent)
            Positioned(
              bottom: 36,
              left: 20,
              right: 20,
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(_waveCtrls.length, (i) {
                    return AnimatedBuilder(
                      animation: _waveCtrls[i],
                      builder: (_, __) {
                        final h = widget.recording
                            ? 6 + _waveCtrls[i].value * 30
                            : 6 + math.sin(i * .7) * 14;
                        return Container(
                          width: 3.5,
                          height: h,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: widget.hasContent && !widget.recording
                                ? widget.accent.withAlpha(130)
                                : widget.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),

          // Pulse rings + mic button
          AnimatedBuilder(
            animation: widget.pulseCtrl,
            builder: (_, child) => Stack(
              alignment: Alignment.center,
              children: [
                if (widget.recording) ...[
                  Container(
                    width: 88 + widget.pulseCtrl.value * 28,
                    height: 88 + widget.pulseCtrl.value * 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accent.withAlpha(
                          (20 * (1 - widget.pulseCtrl.value)).toInt()),
                    ),
                  ),
                  Container(
                    width: 72 + widget.pulseCtrl.value * 12,
                    height: 72 + widget.pulseCtrl.value * 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accent.withAlpha(
                          (30 * (1 - widget.pulseCtrl.value)).toInt()),
                    ),
                  ),
                ],
                child!,
              ],
            ),
            child: GestureDetector(
              onTap: widget.onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: widget.recording ? widget.accent : _kPeach,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.recording ? widget.accent : _kPeachBd,
                    width: 1.5,
                  ),
                  boxShadow: widget.recording
                      ? [
                          BoxShadow(
                            color: widget.accent.withAlpha(60),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ]
                      : const [
                          BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 3)),
                        ],
                ),
                child: Icon(
                  widget.hasContent && !widget.recording
                      ? Icons.play_arrow_rounded
                      : widget.recording
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                  color: widget.recording ? Colors.white : _kBrown,
                  size: 28,
                ),
              ),
            ),
          ),

          // Status label
          Positioned(
            bottom: 13,
            child: Text(
              widget.hasContent && !widget.recording
                  ? '✓  Recording ready  ·  0:12'
                  : widget.recording
                      ? 'Recording…  tap to stop'
                      : 'Tap to start recording',
              style: TextStyle(
                color: widget.recording ? widget.accent : _kMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Letter editor ─────────────────────────────────────────────────────────────

class _LetterEditor extends StatelessWidget {
  const _LetterEditor();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Letterhead strip
          Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7EE),
              border: Border(bottom: BorderSide(color: _kBorder)),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded,
                    color: _kGold, size: 15),
                const SizedBox(width: 8),
                const Text(
                  'To my family, with love…',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'serif',
                  ),
                ),
                const Spacer(),
                Text(
                  'Sealed · 2027',
                  style: TextStyle(
                      color: _kMuted.withAlpha(160), fontSize: 10),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              maxLines: 7,
              style: const TextStyle(
                color: _kBrownDp,
                fontFamily: 'serif',
                fontSize: 14,
                height: 1.7,
              ),
              cursorColor: _kBrown,
              decoration: const InputDecoration(
                hintText:
                    'Dear future family,\n\nWrite what you want them to remember…',
                hintStyle: TextStyle(
                    color: Color(0xFFCFB5A8), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Media uploader ────────────────────────────────────────────────────────────

class _MediaUploader extends StatelessWidget {
  const _MediaUploader({
    required this.type,
    required this.hasContent,
    required this.onUploaded,
  });
  final _MemoryType type;
  final bool hasContent;
  final VoidCallback onUploaded;

  @override
  Widget build(BuildContext context) {
    if (hasContent) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF2FAF3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF9BCDA1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFD6F0D9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF4A9E55), size: 26),
            ),
            const SizedBox(height: 10),
            const Text('File attached',
                style: TextStyle(
                    color: _kBrownDp,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              'Your ${type.label.toLowerCase()} is ready to seal',
              style: const TextStyle(color: _kMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Drop zone
        GestureDetector(
          onTap: onUploaded,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: type.lightBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: type.accent.withAlpha(80)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: type.accent.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(type.icon, color: type.accent, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to choose ${type.label.toLowerCase()}',
                  style: const TextStyle(
                    color: _kBrownDp,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  type == _MemoryType.photo
                      ? 'JPG · PNG · HEIC  ·  max 20 MB'
                      : 'MP4 · MOV  ·  max 100 MB',
                  style:
                      const TextStyle(color: _kMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _UploadPill(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onUploaded),
            const SizedBox(width: 10),
            _UploadPill(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: onUploaded),
          ],
        ),
      ],
    );
  }
}

class _UploadPill extends StatelessWidget {
  const _UploadPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kPeachBd),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: _kBrown),
              const SizedBox(width: 7),
              Text(label,
                  style: const TextStyle(
                      color: _kBrownDp,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Caption input ─────────────────────────────────────────────────────────────

class _CaptionInput extends StatelessWidget {
  const _CaptionInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 6,
              offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 2,
        maxLength: 160,
        style:
            const TextStyle(color: _kBrownDp, fontSize: 13, height: 1.5),
        cursorColor: _kBrown,
        decoration: const InputDecoration(
          hintText: 'Add a caption to this memory…',
          hintStyle:
              TextStyle(color: Color(0xFFCFB5A8), fontSize: 13),
          prefixIcon:
              Icon(Icons.edit_outlined, color: _kMuted, size: 18),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          border: InputBorder.none,
          counterStyle:
              TextStyle(color: Color(0xFFCFB5A8), fontSize: 10),
        ),
      ),
    );
  }
}

// ── Step 3: Review & Seal ─────────────────────────────────────────────────────

class _StepReview extends StatelessWidget {
  const _StepReview({super.key, required this.type, required this.caption});
  final _MemoryType type;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: type.lightBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: type.accent.withAlpha(100)),
              boxShadow: [
                BoxShadow(
                  color: type.accent.withAlpha(20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: type.accent.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(type.icon,
                          color: type.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.label,
                            style: const TextStyle(
                              color: _kBrownDp,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            )),
                        const Text('Ready to seal ✓',
                            style: TextStyle(
                                color: Color(0xFF5E9E65),
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Divider(color: type.accent.withAlpha(50), height: 1),
                  const SizedBox(height: 12),
                  Text(
                    '"$caption"',
                    style: const TextStyle(
                      color: _kBrownDp,
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Metadata rows
          _MetaRow(
              icon: Icons.group_outlined,
              label: 'Visible to',
              value: 'Family contributors only'),
          const SizedBox(height: 9),
          _MetaRow(
              icon: Icons.lock_outline_rounded,
              label: 'Unlocks',
              value: 'April 14, 2027'),
          const SizedBox(height: 9),
          _MetaRow(
              icon: Icons.inventory_2_outlined,
              label: 'Capsule',
              value: 'Family Recipe'),
          const SizedBox(height: 18),

          // Gold note
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7EE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8C68A)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    color: _kGold, size: 15),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Once sealed, this memory cannot be edited until the capsule unlocks.',
                    style: TextStyle(
                        color: _kMuted, fontSize: 11.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 6,
              offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: _kMuted, size: 17),
          const SizedBox(width: 11),
          Text(label,
              style: const TextStyle(color: _kMuted, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                color: _kBrownDp,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomCTA extends StatefulWidget {
  const _BottomCTA({
    required this.step,
    required this.enabled,
    required this.onPressed,
  });
  final int step;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_BottomCTA> createState() => _BottomCTAState();
}

class _BottomCTAState extends State<_BottomCTA>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFinal = widget.step == 2;
    final label = isFinal ? 'Seal Into Capsule' : 'Continue';
    final icon =
        isFinal ? Icons.lock_rounded : Icons.arrow_forward_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: _kBrown.withAlpha(
                          (45 + 45 * _glow.value).toInt()),
                      blurRadius: 14 + 10 * _glow.value,
                      spreadRadius: _glow.value * 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: child,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: widget.enabled ? widget.onPressed : null,
            icon: Icon(icon, size: 16),
            label: Text(
              label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _kBrown,
              disabledBackgroundColor: const Color(0xFFD5C0B8),
              disabledForegroundColor: const Color(0xFFA89390),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Memory type enum ──────────────────────────────────────────────────────────

enum _MemoryType {
  photo(
    label: 'Photo',
    sublabel: 'Capture a moment',
    icon: Icons.photo_camera_outlined,
    accent: Color(0xFFB85C3A),
    lightBg: Color(0xFFFFF3EE),
  ),
  video(
    label: 'Video',
    sublabel: 'A moving memory',
    icon: Icons.videocam_outlined,
    accent: Color(0xFF84321F),
    lightBg: Color(0xFFFFF0EB),
  ),
  voiceNote(
    label: 'Voice',
    sublabel: 'Your voice, preserved',
    icon: Icons.mic_none_rounded,
    accent: Color(0xFF9B4A30),
    lightBg: Color(0xFFFFF5F0),
  ),
  letter(
    label: 'Letter',
    sublabel: 'Words for the future',
    icon: Icons.mail_outline_rounded,
    accent: Color(0xFFD4A24C),
    lightBg: Color(0xFFFFF9EE),
  );

  const _MemoryType({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.accent,
    required this.lightBg,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final Color accent;
  final Color lightBg;
}
