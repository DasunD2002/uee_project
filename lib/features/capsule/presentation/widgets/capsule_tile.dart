import 'package:flutter/material.dart';

// ── Local colour tokens (mirrors app palette) ─────────────────────────────────
const _kBrown   = Color(0xFF84321F);
const _kDeep    = Color(0xFF493027);
const _kMuted   = Color(0xFF6F6560);
const _kPeach   = Color(0xFFFFE3D3);
const _kBorder  = Color(0xFFEEDFD9);

/// Tappable card representing a single time capsule in the vault list.
/// Tapping navigates to [/family-receipt].
class CapsuleTile extends StatefulWidget {
  const CapsuleTile({super.key});

  @override
  State<CapsuleTile> createState() => _CapsuleTileState();
}

class _CapsuleTileState extends State<CapsuleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
    lowerBound: 0,
    upperBound: .012,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open Family Recipe capsule',
      child: GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          Navigator.pushNamed(context, '/family-receipt');
        },
        onTapCancel: () => _press.reverse(),
        child: AnimatedBuilder(
          animation: _press,
          builder: (_, child) =>
              Transform.scale(scale: 1 - _press.value, child: child),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x121E100A),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/login_image.jpg',
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 13),

                // Title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LOCKED chip
                      Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              size: 11, color: _kBrown),
                          const SizedBox(width: 4),
                          const Text(
                            'LOCKED',
                            style: TextStyle(
                              color: _kBrown,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Family recipes',
                        style: TextStyle(
                          color: _kDeep,
                          fontFamily: 'serif',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Locked until April 12, 2026',
                        style: TextStyle(color: _kMuted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),

                // Lock badge + chevron
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: _kPeach, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_outline_rounded,
                          color: _kBrown, size: 16),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: Color(0xFFBBA9A2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
