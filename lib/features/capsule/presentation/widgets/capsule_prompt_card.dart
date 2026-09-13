import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Hero promo card shown on the Capsule dashboard.
/// Tapping [onCreate] navigates to the create-capsule flow.
class CapsulePromptCard extends StatefulWidget {
  const CapsulePromptCard({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<CapsulePromptCard> createState() => _CapsulePromptCardState();
}

class _CapsulePromptCardState extends State<CapsulePromptCard>
    with SingleTickerProviderStateMixin {
  // Subtle glow pulse on the CTA button
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x201D0A04),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo hero area ─────────────────────────────────────────────
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/login_image.jpg',
                  fit: BoxFit.cover,
                ),
                // Gradient vignette
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0xAA2B0E04),
                      ],
                      stops: [.3, 1],
                    ),
                  ),
                ),
                // MEMORY VAULT badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xEFFFFFFB),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 13, color: AppColors.brown),
                        SizedBox(width: 5),
                        Text(
                          'MEMORY VAULT',
                          style: TextStyle(
                            color: AppColors.brown,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Headline over image
                const Positioned(
                  left: 16,
                  bottom: 16,
                  right: 60,
                  child: Text(
                    'Save what matters\nfor later.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: .97,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A little time capsule for a big life.',
                  style: TextStyle(
                    color: Color(0xFF39241D),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gather your stories, recipes and wishes.\nChoose when they should be opened again.',
                  style: TextStyle(
                    color: Color(0xFF7A6A65),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // ── CTA button with glow ────────────────────────────────
                AnimatedBuilder(
                  animation: _glow,
                  builder: (_, child) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brown.withAlpha(
                              (40 + 50 * _glow.value).toInt()),
                          blurRadius: 12 + 8 * _glow.value,
                          spreadRadius: _glow.value,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: widget.onCreate,
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 17),
                      label: const Text(
                        'Create Your First Capsule',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                    ),
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
