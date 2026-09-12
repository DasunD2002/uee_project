import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';

/// The contents of Kumari's family-recipe time capsule.
class FamilyReceiptScreen extends StatelessWidget {
  const FamilyReceiptScreen({super.key});

  void _onNavSelected(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    } else if (index == 3) {
      Navigator.pushNamedAndRemoveUntil(context, '/capsules', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8EF),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFF8EF),
      foregroundColor: AppColors.brown,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Back to capsules',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
      ),
      title: const Text('Your capsule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Share capsule',
          onPressed: () {},
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
            // ── Title ──────────────────────────────────────────────────
            const Text(
              'Family Recipe',
              style: TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            // ── Unlock status badge ─────────────────────────────────────
            const _UnlockBadge(),
            const SizedBox(height: 10),

            // ── Contributor avatars + memory counter ────────────────────
            const _MetaRow(),
            const SizedBox(height: 18),

            // ── Polaroid scatter ────────────────────────────────────────
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
                    ),
                    _MemoryCard(
                      alignment: const Alignment(.72, -.58),
                      angle: .08,
                      image: 'assets/images/gal_vihara.png',
                      caption: 'The family table',
                    ),
                    _MemoryCard(
                      alignment: const Alignment(-.62, .62),
                      angle: .03,
                      image: 'assets/images/mask_carver.png',
                      caption: 'Her blessing',
                    ),
                    _LetterCard(),
                    // ── Video Polaroid (replaces bare play circle) ──────
                    _VideoCard(
                      alignment: const Alignment(.10, -.05),
                      angle: -.02,
                      image: 'assets/images/gal_vihara.png',
                      onPlay: () => _showVideoPlayer(context),
                    ),
                  ],
                ),
              ),
            ),

            // ── Secondary CTA ───────────────────────────────────────────
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text(
                  'Add More Memories',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brown,
                  side: const BorderSide(color: Color(0xFFD9B49E), width: 1.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFFFFF3E8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Primary CTA ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 47,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/family-memories'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                child: const Text('View Your Memories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: ExplorerFooter(selectedIndex: 3, onSelected: (index) => _onNavSelected(context, index)),
  );

  // ── Video player modal ──────────────────────────────────────────────────────
  void _showVideoPlayer(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/gal_vihara.png', fit: BoxFit.cover),
                    const ColoredBox(color: Color(0x66000000)),
                    const Center(
                      child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 64),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Watch Family Video · 0:45',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Unlock badge ──────────────────────────────────────────────────────────────

class _UnlockBadge extends StatelessWidget {
  const _UnlockBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFECDB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8C5A8)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.brown),
        SizedBox(width: 5),
        Text(
          'Unlocks on April 14, 2027',
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Meta row (contributor avatars + memory counter) ───────────────────────────

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
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      const Text(
        'Added by Grandma, Uncle & You',
        style: TextStyle(color: Color(0xFFA07060), fontSize: 11),
      ),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.brown,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '4 Memories',
          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

// ── Video Polaroid card ───────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.alignment,
    required this.angle,
    required this.image,
    required this.onPlay,
  });
  final Alignment alignment;
  final double angle;
  final String image;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Transform.rotate(
      angle: angle,
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          width: 115,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: const [
              BoxShadow(color: Color(0x2A4D3022), blurRadius: 12, offset: Offset(0, 5)),
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
                    Image.asset(image, height: 94, width: double.infinity, fit: BoxFit.cover),
                    Container(
                      height: 94,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x33000000), Color(0xAA000000)],
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
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.brown, size: 22),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '0:45',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
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
                  color: AppColors.brown,
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
  );
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.alignment, required this.angle, required this.image, required this.caption});
  final Alignment alignment;
  final double angle;
  final String image;
  final String caption;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Transform.rotate(
      angle: angle,
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), boxShadow: const [BoxShadow(color: Color(0x1A4D3022), blurRadius: 9, offset: Offset(0, 4))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.asset(image, height: 94, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 7),
          Text(caption, style: const TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 10, fontStyle: FontStyle.italic)),
        ]),
      ),
    ),
  );
}

class _LetterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
    alignment: const Alignment(.63, .64),
    child: Container(
      width: 106,
      height: 115,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), boxShadow: const [BoxShadow(color: Color(0x1A4D3022), blurRadius: 9, offset: Offset(0, 4))]),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.mail_outline_rounded, color: Color(0xFFC17B4F), size: 30),
        SizedBox(height: 20),
        Text('A letter for you', style: TextStyle(color: AppColors.brown, fontFamily: 'serif', fontSize: 10)),
      ]),
    ),
  );
}
