import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../../core/services/notification_service.dart';
import '../data/capsule_service.dart';
import '../domain/capsule_memory.dart';
import '../domain/capsule_model.dart';
import 'widgets/add_memory_picker_sheet.dart';
import 'widgets/contributor_sheet.dart';
import 'widgets/memory_viewer_sheet.dart';
import 'widgets/voice_note_recorder_sheet.dart';

// ── Local colour tokens ──────────────────────────────────────────────────────
const _kBrown     = Color(0xFF84321F);
const _kBrownDeep = Color(0xFF5A1E0E);
const _kMuted     = Color(0xFFA07060);
const _kBorder    = Color(0xFFEEDFD9);
const _kPeach     = Color(0xFFFFF3E8);
const _kPeachBd   = Color(0xFFD9B49E);

/// The contents of Kumari's family-recipe time capsule.
class FamilyReceiptScreen extends StatefulWidget {
  const FamilyReceiptScreen({super.key});

  @override
  State<FamilyReceiptScreen> createState() => _FamilyReceiptScreenState();
}

class _FamilyReceiptScreenState extends State<FamilyReceiptScreen>
    with TickerProviderStateMixin {
  final CapsuleService _capsuleService = CapsuleService();
  CapsuleModel? _capsule;
  Timer? _countdownTicker;

  @override
  void initState() {
    super.initState();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _capsule != null) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CapsuleModel && _capsule == null) {
      _capsule = args;
      _reloadCapsule();
    }
  }

  Future<void> _reloadCapsule() async {
    if (_capsule?.id == null) return;
    final updated = await _capsuleService.getCapsuleById(_capsule!.id!);
    if (updated != null && mounted) {
      setState(() => _capsule = updated);
      if (updated.parsedUnlockDate != null) {
        NotificationService().scheduleCapsuleUnlock(
          capsuleId: updated.id ?? 'capsule',
          title: updated.title,
          unlockDate: updated.parsedUnlockDate!,
        );
      }
    }
  }

  // Glow pulse on the primary CTA
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  void _onNavSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, '/capsules', (_) => false);
    }
  }

  @override
  void dispose() {
    _countdownTicker?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onCardTap(CapsuleMemory memory) {
    if (_capsule?.isLocked() == true) {
      MemoryViewer.showSealedSheet(
        context,
        unlockDate: _capsule?.formattedUnlockDate ?? 'Future Date',
        countdownString: _capsule?.countdownString,
      );
    } else {
      MemoryViewer.show(context, memory);
    }
  }

  Future<void> _onAddMemory() async {
    if (_capsule?.isUnlocked() == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This capsule is unlocked! Adding memories is disabled.')),
      );
      return;
    }

    final newMemory = await AddMemoryPickerSheet.show(context);
    if (newMemory != null && mounted) {
      final updated = await _capsuleService.addMemory(_capsule?.id ?? '', newMemory);
      if (updated != null && mounted) {
        setState(() => _capsule = updated);
      } else if (mounted) {
        setState(() {
          _capsule = _capsule!.copyWith(
            memories: [newMemory, ..._capsule!.memories],
          );
        });
      }
      if (mounted) {
        NotificationService().showNotification(
          title: 'Memory Sealed ✦',
          body: 'New ${newMemory.type.displayName.toLowerCase()} preserved in "${_capsule?.title ?? 'Family Capsule'}".',
          icon: Icons.lock_rounded,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Memory sealed into your capsule ✦')),
        );
      }
    }
  }

  Future<void> _onVoiceNote() async {
    if (_capsule?.isUnlocked() == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This capsule is unlocked! Adding memories is disabled.')),
      );
      return;
    }

    final voiceMemory = await VoiceNoteRecorderSheet.show(context);
    if (voiceMemory != null && mounted) {
      final updated = await _capsuleService.addMemory(_capsule?.id ?? '', voiceMemory);
      if (updated != null && mounted) {
        setState(() => _capsule = updated);
      } else if (mounted) {
        setState(() {
          _capsule = _capsule!.copyWith(
            memories: [voiceMemory, ..._capsule!.memories],
          );
        });
      }
      if (mounted) {
        NotificationService().showNotification(
          title: 'Voice Note Sealed 🎙️',
          body: 'Voice note preserved in "${_capsule?.title ?? 'Family Capsule'}".',
          icon: Icons.mic_rounded,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice note sealed into your capsule ✦')),
        );
      }
    }
  }

  void _shareCapsule(BuildContext context) {
    if (_capsule == null) return;
    final title = _capsule!.title.isNotEmpty ? _capsule!.title : 'Family Recipe';
    final date = _capsule!.formattedUnlockDate;
    final link = 'https://rootly.app/capsule/${_capsule!.id ?? "family"}';
    SharePlus.instance.share(
      ShareParams(
        text: "Preserving precious memories in my Time Capsule '$title' on Rootly! It unlocks on $date.\nJoin here: $link",
        subject: "Time Capsule: $title",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memories = (_capsule?.memories.isNotEmpty == true)
        ? _capsule!.memories
        : CapsuleService.defaultMemories();

    final mem0 = memories.isNotEmpty ? memories[0] : null;
    final mem1 = memories.length > 1 ? memories[1] : null;
    final mem2 = memories.length > 2 ? memories[2] : null;
    final memVideo = memories.firstWhere(
      (m) => m.type == MemoryType.video,
      orElse: () => memories.isNotEmpty ? memories[0] : CapsuleMemory(
        id: 'mock_vid',
        type: MemoryType.video,
        content: 'assets/images/gal_vihara.png',
        title: 'Watch Family Video',
        addedBy: 'Uncle',
        createdAt: DateTime.now(),
      ),
    );
    final memLetter = memories.firstWhere(
      (m) => m.type == MemoryType.letter,
      orElse: () => CapsuleMemory(
        id: 'mock_let',
        type: MemoryType.letter,
        content: 'A letter for you',
        title: 'A letter for you',
        addedBy: 'Grandma',
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EF),
        foregroundColor: _kBrown,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back to capsules',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text(
          'Your capsule',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Edit capsule',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/edit-capsule',
                arguments: _capsule,
              );
              if (!mounted) return;
              if (result is CapsuleModel) {
                setState(() => _capsule = result);
              } else if (result == true) {
                _reloadCapsule();
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Share capsule',
            onPressed: () => _shareCapsule(context),
            icon: const Icon(Icons.ios_share_rounded, size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 28),
          child: Column(
            children: [
              // ── Title ─────────────────────────────────────────────────
              Text(
                _capsule?.title.isNotEmpty == true
                    ? _capsule!.title
                    : 'Family Recipe',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _kBrown,
                  fontFamily: 'serif',
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_capsule?.description.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _capsule!.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kMuted, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 8),

              // ── Unlock status badge ────────────────────────────────────
              _UnlockBadge(capsule: _capsule),

              if (kDebugMode) ...[
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    if (_capsule == null) return;
                    final updated = await _capsuleService.toggleDebugUnlock(_capsule!.id ?? '');
                    if (updated != null && mounted) {
                      setState(() => _capsule = updated);
                    } else if (mounted) {
                      setState(() {
                        _capsule = _capsule!.copyWith(isDebugUnlocked: !_capsule!.isDebugUnlocked);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _capsule?.isUnlocked() == true
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _capsule?.isUnlocked() == true
                            ? Colors.green
                            : Colors.orange,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _capsule?.isUnlocked() == true
                              ? Icons.lock_open_rounded
                              : Icons.lock_clock_rounded,
                          size: 11,
                          color: _capsule?.isUnlocked() == true
                              ? Colors.green[800]
                              : Colors.orange[900],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _capsule?.isUnlocked() == true
                              ? 'DEV: UNLOCKED (Tap to Lock)'
                              : 'DEV: LOCKED (Tap to Unlock)',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: _capsule?.isUnlocked() == true
                                ? Colors.green[800]
                                : Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // ── Contributor avatars + memory counter ───────────────────
              _MetaRow(
                capsule: _capsule,
                onInvite: () {
                  if (_capsule == null) return;
                  ContributorSheet.show(
                    context,
                    capsule: _capsule!,
                    onCapsuleUpdated: (updated) => setState(() => _capsule = updated),
                  );
                },
              ),
              const SizedBox(height: 18),

              // ── Polaroid scatter ───────────────────────────────────────
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (mem0 != null)
                        _MemoryCard(
                          alignment: const Alignment(-.72, -.72),
                          angle: -.04,
                          image: mem0.content.isNotEmpty ? mem0.content : 'assets/images/login_image.jpg',
                          caption: mem0.caption ?? mem0.title ?? 'Aachchi te ka',
                          elevation: 1,
                          onTap: () => _onCardTap(mem0),
                        ),
                      if (mem1 != null)
                        _MemoryCard(
                          alignment: const Alignment(.72, -.58),
                          angle: .08,
                          image: mem1.content.isNotEmpty ? mem1.content : 'assets/images/gal_vihara.png',
                          caption: mem1.caption ?? mem1.title ?? 'The family table',
                          elevation: 2,
                          onTap: () => _onCardTap(mem1),
                        ),
                      if (mem2 != null)
                        _MemoryCard(
                          alignment: const Alignment(-.62, .62),
                          angle: .03,
                          image: mem2.content.isNotEmpty ? mem2.content : 'assets/images/mask_carver.png',
                          caption: mem2.caption ?? mem2.title ?? 'Her blessing',
                          elevation: 2,
                          onTap: () => _onCardTap(mem2),
                        ),
                      _LetterCard(
                        onTap: () => _onCardTap(memLetter),
                      ),
                      // ── Video Polaroid ─────────────────────────────────
                      _AnimatedVideoCard(
                        alignment: const Alignment(.10, -.05),
                        angle: -.02,
                        image: memVideo.content.isNotEmpty ? memVideo.content : 'assets/images/gal_vihara.png',
                        onTap: () => _onCardTap(memVideo),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action buttons row ─────────────────────────────────────
              const SizedBox(height: 12),
              _ActionButtonsRow(
                isLocked: _capsule?.isLocked() ?? true,
                onAddMemory: _onAddMemory,
                onVoiceNote: _onVoiceNote,
              ),
              const SizedBox(height: 10),

              // ── Primary CTA with glow ──────────────────────────────────
              _GlowCTA(
                glowCtrl: _glowCtrl,
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    '/family-memories',
                    arguments: _capsule,
                  );
                  _reloadCapsule();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 3,
        onSelected: (index) => _onNavSelected(context, index),
      ),
    );
  }
}

// ── Action buttons row ────────────────────────────────────────────────────────

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.onAddMemory,
    required this.onVoiceNote,
    this.isLocked = true,
  });
  final VoidCallback onAddMemory;
  final VoidCallback onVoiceNote;
  final bool isLocked;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isLocked ? onAddMemory : null,
                icon: const Icon(Icons.add_rounded, size: 17),
                label: Text(
                  isLocked ? 'Add Memory' : 'Capsule Opened',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBrown,
                  disabledForegroundColor: _kMuted,
                  side: BorderSide(color: isLocked ? _kPeachBd : _kBorder, width: 1.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: isLocked ? _kPeach : const Color(0xFFF7F2EE),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: isLocked ? onVoiceNote : null,
                icon: const Icon(Icons.mic_none_rounded, size: 17),
                label: Text(
                  isLocked ? 'Voice Note' : 'Sealed',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBrown,
                  disabledForegroundColor: _kMuted,
                  side: BorderSide(color: isLocked ? _kPeachBd : _kBorder, width: 1.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: isLocked ? const Color(0xFFFFF8F0) : const Color(0xFFF7F2EE),
                ),
              ),
            ),
          ),
        ],
      );
}

// ── Glow CTA ──────────────────────────────────────────────────────────────────

class _GlowCTA extends StatelessWidget {
  const _GlowCTA({required this.glowCtrl, required this.onPressed});
  final AnimationController glowCtrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowCtrl,
      builder: (_, child) => Container(
        width: double.infinity,
        height: 47,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color:
                  _kBrown.withAlpha((60 + 80 * glowCtrl.value).toInt()),
              blurRadius: 14 + 10 * glowCtrl.value,
              spreadRadius: glowCtrl.value * 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _kBrown,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Text(
          'View Your Memories',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Unlock badge ──────────────────────────────────────────────────────────────

class _UnlockBadge extends StatefulWidget {
  const _UnlockBadge({this.capsule});
  final CapsuleModel? capsule;

  @override
  State<_UnlockBadge> createState() => _UnlockBadgeState();
}

class _UnlockBadgeState extends State<_UnlockBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final Animation<double> _wobbleAnim = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: .08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1),
    TweenSequenceItem(
        tween: Tween(begin: .08, end: -.08)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2),
    TweenSequenceItem(
        tween: Tween(begin: -.08, end: .06)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2),
    TweenSequenceItem(
        tween: Tween(begin: .06, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1),
  ]).animate(_wobble);

  late Timer _idleTimer;

  @override
  void initState() {
    super.initState();
    _idleTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _wobble.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _idleTimer.cancel();
    _wobble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.capsule?.isUnlocked() == true;
    final displayDate = widget.capsule?.formattedUnlockDate ?? 'April 14, 2027';

    return GestureDetector(
      onTap: () {
        _wobble.forward(from: 0);
        _showCountdown(context);
      },
      child: AnimatedBuilder(
        animation: _wobbleAnim,
        builder: (_, child) => Transform.rotate(
          angle: _wobbleAnim.value,
          child: child,
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFFE8F5E9) : const Color(0xFFFFECDB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isUnlocked ? Colors.green.shade400 : const Color(0xFFE8C5A8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 12,
                color: isUnlocked ? Colors.green.shade800 : _kBrown,
              ),
              const SizedBox(width: 5),
              Text(
                isUnlocked
                    ? '✦ Unlocked · Tap to view ✦'
                    : 'Unlocks on $displayDate (${widget.capsule?.countdownString ?? ""})',
                style: TextStyle(
                  color: isUnlocked ? Colors.green.shade800 : _kBrown,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountdown(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountdownSheet(capsule: widget.capsule),
    );
  }
}

// ── Countdown sheet ───────────────────────────────────────────────────────────

class _CountdownSheet extends StatefulWidget {
  const _CountdownSheet({this.capsule});
  final CapsuleModel? capsule;

  @override
  State<_CountdownSheet> createState() => _CountdownSheetState();
}

class _CountdownSheetState extends State<_CountdownSheet> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _calcRemaining());
    });
  }

  Duration _calcRemaining() {
    if (widget.capsule?.isUnlocked() == true) return Duration.zero;
    final target = widget.capsule?.parsedUnlockDate ?? DateTime(2027, 4, 14);
    final diff = target.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.capsule?.isUnlocked() == true;
    final displayDate = widget.capsule?.formattedUnlockDate ?? 'April 14, 2027';
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFD9C4BC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
            color: isUnlocked ? Colors.green.shade800 : _kBrown,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            isUnlocked ? 'Capsule is Unlocked!' : 'Sealed Until $displayDate',
            style: const TextStyle(
              color: _kBrownDeep,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isUnlocked
                ? 'All memories inside are now available to view.'
                : 'This capsule will open in…',
            style: const TextStyle(color: _kMuted, fontSize: 12),
          ),
          const SizedBox(height: 22),
          if (!isUnlocked) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CountUnit(value: d, label: 'Days'),
                _CountSep(),
                _CountUnit(value: h, label: 'Hrs'),
                _CountSep(),
                _CountUnit(value: m, label: 'Min'),
                _CountSep(),
                _CountUnit(value: s, label: 'Sec'),
              ],
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (isUnlocked) {
                  Navigator.pushNamed(context, '/family-memories', arguments: widget.capsule);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: _kBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isUnlocked ? 'View Your Memories' : 'Got it',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountUnit extends StatelessWidget {
  const _CountUnit({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: _kBrown,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: _kMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _CountSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(':',
            style: TextStyle(
                color: _kBrown, fontSize: 24, fontWeight: FontWeight.w700)),
      );
}

// ── Meta row (contributor avatars + memory counter + invite) ─────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({this.capsule, this.onInvite});
  final CapsuleModel? capsule;
  final VoidCallback? onInvite;

  static const _avatarColors = [
    Color(0xFFD4A89A),
    Color(0xFF9BC4B2),
    Color(0xFFA8BDD4),
    Color(0xFFE2B084),
  ];

  @override
  Widget build(BuildContext context) {
    final contributors = capsule?.contributors.isNotEmpty == true
        ? capsule!.contributors
        : ['Grandma', 'Uncle', 'You'];
    final count = capsule?.memories.isNotEmpty == true ? capsule!.memories.length : 4;

    String contributorText;
    if (contributors.length == 1) {
      contributorText = 'Added by ${contributors[0]}';
    } else if (contributors.length == 2) {
      contributorText = 'Added by ${contributors[0]} & ${contributors[1]}';
    } else {
      contributorText = 'Added by ${contributors.take(2).join(", ")} & You';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: (contributors.take(3).length * 16.0) + 8,
          height: 22,
          child: Stack(
            children: [
              for (var i = 0; i < contributors.take(3).length; i++)
                Positioned(
                  left: i * 16.0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _avatarColors[i % _avatarColors.length],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      contributors[i].isNotEmpty ? contributors[i][0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            contributorText,
            style: const TextStyle(color: _kMuted, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onInvite,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _kBrown.withAlpha(120), width: 1.3),
              boxShadow: const [
                BoxShadow(color: Color(0x15000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.person_add_rounded, size: 11, color: _kBrown),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _kBrown,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count Memories',
            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ── Animated video card (polaroid with play/pause inside) ────────────────────

class _AnimatedVideoCard extends StatefulWidget {
  const _AnimatedVideoCard({
    required this.alignment,
    required this.angle,
    required this.image,
    this.onTap,
  });
  final Alignment alignment;
  final double angle;
  final String image;
  final VoidCallback? onTap;

  @override
  State<_AnimatedVideoCard> createState() => _AnimatedVideoCardState();
}

class _AnimatedVideoCardState extends State<_AnimatedVideoCard>
    with SingleTickerProviderStateMixin {
  // Subtle idle bob animation
  late final AnimationController _bobCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final Animation<double> _bobY = Tween<double>(begin: -2, end: 2)
      .animate(
          CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _bobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _bobY,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _bobY.value),
          child: child,
        ),
        child: Transform.rotate(
          angle: widget.angle,
          child: GestureDetector(
            onTap: widget.onTap ?? () => _openVideoPlayer(context),
            child: Container(
              width: 115,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x354D3022),
                      blurRadius: 18,
                      offset: Offset(0, 7)),
                  BoxShadow(
                      color: Color(0x1A4D3022),
                      blurRadius: 5,
                      offset: Offset(2, 3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          widget.image,
                          height: 94,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          height: 94,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x33000000),
                                Color(0xAA000000)
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: _kBrown,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '0:45',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Watch Family Video',
                    style: TextStyle(
                      color: _kBrown,
                      fontFamily: 'serif',
                      fontSize: 9.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (ctx, anim, _) => FadeTransition(
          opacity: anim,
          child: _VideoPlayerPage(image: widget.image),
        ),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

// ── Full-screen animated video player ────────────────────────────────────────

class _VideoPlayerPage extends StatefulWidget {
  const _VideoPlayerPage({required this.image});
  final String image;

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage>
    with TickerProviderStateMixin {
  // Progress (0..1 over 45 s)
  late final AnimationController _progressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 45),
  );

  bool _playing = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  // Slide-up entry animation
  late final AnimationController _entryCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  late final Animation<Offset> _slideAnim = Tween<Offset>(
    begin: const Offset(0, .12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _progressCtrl.dispose();
    _entryCtrl.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _progressCtrl.forward();
      _scheduleHideControls();
    } else {
      _progressCtrl.stop();
      _showControls();
    }
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _hideTimer?.cancel();
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _playing) setState(() => _controlsVisible = false);
    });
  }

  void _onTapVideo() {
    if (_controlsVisible) {
      _togglePlay();
    } else {
      _showControls();
      _scheduleHideControls();
    }
  }

  String _formatDuration(double progress) {
    const total = Duration(seconds: 45);
    final elapsed = total * progress;
    final s = elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(1, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

            // Video frame
            SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: GestureDetector(
                      onTap: _onTapVideo,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail
                          Image.asset(widget.image, fit: BoxFit.cover),

                          // Dark overlay
                          const ColoredBox(color: Color(0x55000000)),

                          // Controls overlay
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: _controlsVisible ? 1.0 : 0.0,
                            child: _buildControls(),
                          ),

                          // Bottom scrubber bar
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildScrubber(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
            // Title + elapsed
            AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, __) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_movies_outlined,
                      color: Colors.white54, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Watch Family Video  ·  ${_formatDuration(_progressCtrl.value)} / 0:45',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Center(
      child: GestureDetector(
        onTap: _togglePlay,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Container(
            key: ValueKey(_playing),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(
              _playing
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: _kBrown,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrubber() {
    return AnimatedBuilder(
      animation: _progressCtrl,
      builder: (_, __) {
        final val = _progressCtrl.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seek bar
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final width = box.size.width;
                final dx = (details.localPosition.dx / width)
                    .clamp(0.0, 1.0);
                _progressCtrl.value = dx;
              },
              child: Container(
                height: 36,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Progress fill
                    FractionallySizedBox(
                      widthFactor: val,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: val *
                          (MediaQuery.of(context).size.width -
                              32 - // padding
                              6) - // thumb radius
                          3,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Memory card (3-D depth polaroid) ─────────────────────────────────────────

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.alignment,
    required this.angle,
    required this.image,
    required this.caption,
    this.elevation = 1,
    this.onTap,
  });
  final Alignment alignment;
  final double angle;
  final String image;
  final String caption;
  final int elevation;
  final VoidCallback? onTap;

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, height: 94, width: double.infinity, fit: BoxFit.cover);
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, height: 94, width: double.infinity, fit: BoxFit.cover);
    } else {
      try {
        final f = File(path);
        if (f.existsSync()) {
          return Image.file(f, height: 94, width: double.infinity, fit: BoxFit.cover);
        }
      } catch (_) {}
      return Image.asset('assets/images/login_image.jpg', height: 94, width: double.infinity, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateZ(angle)
            ..rotateX(angle * .4),
          alignment: FractionalOffset.center,
          child: Container(
            width: 108,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x2A4D3022),
                  blurRadius: 8 + elevation * 6.0,
                  offset: Offset(0, 3 + elevation * 2.0),
                ),
                BoxShadow(
                  color: const Color(0x124D3022),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: _buildImage(image),
                ),
                const SizedBox(height: 7),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kBrown,
                    fontFamily: 'serif',
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Letter card ───────────────────────────────────────────────────────────────

class _LetterCard extends StatelessWidget {
  const _LetterCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: const Alignment(.63, .64),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 106,
            height: 115,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x2A4D3022),
                    blurRadius: 14,
                    offset: Offset(0, 6)),
                BoxShadow(
                    color: Color(0x104D3022),
                    blurRadius: 4,
                    offset: Offset(2, 2)),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline_rounded,
                    color: Color(0xFFC17B4F), size: 30),
                SizedBox(height: 20),
                Text(
                  'A letter for you',
                  style: TextStyle(
                    color: _kBrown,
                    fontFamily: 'serif',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
