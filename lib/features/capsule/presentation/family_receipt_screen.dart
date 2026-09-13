import 'dart:async';

import 'package:flutter/material.dart';

import '../../explorer/presentation/widgets/explorer_footer.dart';
import 'add_memory_screen.dart';

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
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              tooltip: 'Share capsule',
              onPressed: () => _showShareSheet(context),
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
                const Text(
                  'Family Recipe',
                  style: TextStyle(
                    color: _kBrown,
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Unlock status badge ────────────────────────────────────
                const _UnlockBadge(),
                const SizedBox(height: 10),

                // ── Contributor avatars + memory counter ───────────────────
                const _MetaRow(),
                const SizedBox(height: 18),

                // ── Polaroid scatter ───────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _MemoryCard(
                          alignment: const Alignment(-.72, -.72),
                          angle: -.04,
                          image: 'assets/images/login_image.jpg',
                          caption: 'Aachchi te ka',
                          elevation: 1,
                        ),
                        _MemoryCard(
                          alignment: const Alignment(.72, -.58),
                          angle: .08,
                          image: 'assets/images/gal_vihara.png',
                          caption: 'The family table',
                          elevation: 2,
                        ),
                        _MemoryCard(
                          alignment: const Alignment(-.62, .62),
                          angle: .03,
                          image: 'assets/images/mask_carver.png',
                          caption: 'Her blessing',
                          elevation: 2,
                        ),
                        _LetterCard(),
                        // ── Video Polaroid ─────────────────────────────────
                        _AnimatedVideoCard(
                          alignment: const Alignment(.10, -.05),
                          angle: -.02,
                          image: 'assets/images/gal_vihara.png',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Action buttons row ─────────────────────────────────────
                const SizedBox(height: 12),
                _ActionButtonsRow(
                  onAddMemory: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddMemoryScreen(),
                    ),
                  ),
                  onVoiceNote: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddMemoryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Primary CTA with glow ──────────────────────────────────
                _GlowCTA(
                  glowCtrl: _glowCtrl,
                  onPressed: () =>
                      Navigator.pushNamed(context, '/family-memories'),
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

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ShareSheet(),
    );
  }
}

// ── Action buttons row ────────────────────────────────────────────────────────

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.onAddMemory,
    required this.onVoiceNote,
  });
  final VoidCallback onAddMemory;
  final VoidCallback onVoiceNote;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onAddMemory,
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text(
                  'Add Memory',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBrown,
                  side: const BorderSide(color: _kPeachBd, width: 1.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: _kPeach,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onVoiceNote,
                icon: const Icon(Icons.mic_none_rounded, size: 17),
                label: const Text(
                  'Voice Note',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kBrown,
                  side: const BorderSide(color: _kPeachBd, width: 1.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFFFFF8F0),
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
  const _UnlockBadge();

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
            color: const Color(0xFFFFECDB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8C5A8)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 12, color: _kBrown),
              SizedBox(width: 5),
              Text(
                'Unlocks on April 14, 2027',
                style: TextStyle(
                  color: _kBrown,
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
      builder: (_) => const _CountdownSheet(),
    );
  }
}

// ── Countdown sheet ───────────────────────────────────────────────────────────

class _CountdownSheet extends StatefulWidget {
  const _CountdownSheet();

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
    final target = DateTime(2027, 4, 14);
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
          const Icon(Icons.lock_outline_rounded, color: _kBrown, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Sealed Until April 14, 2027',
            style: TextStyle(
              color: _kBrownDeep,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'This capsule will open in…',
            style: TextStyle(color: _kMuted, fontSize: 12),
          ),
          const SizedBox(height: 22),
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
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: _kBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it',
                  style: TextStyle(fontWeight: FontWeight.w700)),
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
  const _MetaRow();

  static const _avatarColors = [
    Color(0xFFD4A89A),
    Color(0xFF9BC4B2),
    Color(0xFFA8BDD4),
  ];

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 22,
            child: Stack(
              children: [
                for (var i = 0; i < _avatarColors.length; i++)
                  Positioned(
                    left: i * 16.0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _avatarColors[i],
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Flexible(
            child: Text(
              'Added by Grandma, Uncle & You',
              style: TextStyle(color: _kMuted, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          // ── Invite button ────────────────────────────────────────────
          GestureDetector(
            onTap: () => _showInviteSheet(context),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: _kBrown.withAlpha(120),
                    width: 1.3),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 4,
                      offset: Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.person_add_rounded,
                  size: 11, color: _kBrown),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _kBrown,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '4 Memories',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ShareSheet(),
    );
  }
}

// ── Share / Invite sheet ─────────────────────────────────────────────────────

class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD9C4BC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Invite Family Members',
            style: TextStyle(
              color: _kBrownDeep,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share this capsule with loved ones',
            style: TextStyle(color: _kMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          // Invite options
          _InviteOption(
            icon: Icons.link_rounded,
            label: 'Copy invite link',
            sublabel: 'rootly.app/capsule/FamilyRecipe',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _InviteOption(
            icon: Icons.mail_outline_rounded,
            label: 'Invite via Email',
            sublabel: 'Send a link to their inbox',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _InviteOption(
            icon: Icons.message_outlined,
            label: 'Invite via Message',
            sublabel: 'Share through SMS or WhatsApp',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kBrown,
                side: const BorderSide(color: _kPeachBd),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteOption extends StatelessWidget {
  const _InviteOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECDB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _kBrown, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: _kBrownDeep,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
                Text(sublabel,
                    style: const TextStyle(
                        color: _kMuted, fontSize: 10.5)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: _kMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Animated video card (polaroid with play/pause inside) ────────────────────

class _AnimatedVideoCard extends StatefulWidget {
  const _AnimatedVideoCard({
    required this.alignment,
    required this.angle,
    required this.image,
  });
  final Alignment alignment;
  final double angle;
  final String image;

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
            onTap: () => _openVideoPlayer(context),
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
  });
  final Alignment alignment;
  final double angle;
  final String image;
  final String caption;
  final int elevation;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
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
                child: Image.asset(
                  image,
                  height: 94,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                caption,
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
    );
  }
}

// ── Letter card ───────────────────────────────────────────────────────────────

class _LetterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
        alignment: const Alignment(.63, .64),
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
      );
}
