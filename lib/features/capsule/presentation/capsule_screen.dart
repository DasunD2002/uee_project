import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/capsule_prompt_card.dart';
import 'widgets/capsule_tile.dart';

// ── Local palette ─────────────────────────────────────────────────────────────
const _kBg      = Color(0xFFFDF8F5);
const _kBrown   = Color(0xFF84321F);
const _kDeep    = Color(0xFF39231B);
const _kMuted   = Color(0xFF6B5D58);
const _kBorder  = Color(0xFFEEDFD9);
const _kPeach   = Color(0xFFFFE8DA);

/// Dashboard reached from the Capsule item in the primary navigation.
class CapsuleScreen extends StatelessWidget {
  const CapsuleScreen({super.key});

  void _onNavSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _kBg,
        drawer: const HomeDrawer(selectedSection: 'Time capsule'),
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: _kBg,
          foregroundColor: _kBrown,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Rootly',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _kBrown,
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              tooltip: 'Open menu',
              icon: const Icon(Icons.menu_rounded, size: 21),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Icon(Icons.notifications_none_rounded, size: 21),
            ),
            const SizedBox(width: 4),
          ],
          // Thin bottom divider instead of shadow
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: _kBorder),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero greeting ─────────────────────────────────────────────
              const Text(
                'Your stories,\nbeautifully kept.',
                style: TextStyle(
                  color: _kDeep,
                  fontSize: 31,
                  height: .97,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ayubowan, Kumari  ·  your legacy vault',
                style: TextStyle(
                  color: _kMuted,
                  fontFamily: 'serif',
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 26),

              // ── Stat chips row ────────────────────────────────────────────
              const _StatRow(),
              const SizedBox(height: 24),

              // ── Prompt / hero card ────────────────────────────────────────
              CapsulePromptCard(
                onCreate: () =>
                    Navigator.pushNamed(context, '/create-capsule'),
              ),
              const SizedBox(height: 28),

              // ── Section header ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'YOUR TIME CAPSULES',
                    style: TextStyle(
                      color: Color(0xFF574640),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/family-receipt'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kPeach,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDDB69E)),
                      ),
                      child: const Text(
                        '1 protected',
                        style: TextStyle(
                          color: _kBrown,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const CapsuleTile(),
              const SizedBox(height: 14),

              // ── Empty state hint ──────────────────────────────────────────
              _EmptyStateHint(
                onTap: () =>
                    Navigator.pushNamed(context, '/create-capsule'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ExplorerFooter(
          selectedIndex: 3,
          onSelected: (index) => _onNavSelected(context, index),
        ),
      );
}

// ── Stat chips ────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _StatChip(
            icon: Icons.lock_clock_outlined,
            value: '01',
            label: 'Capsules',
            bg: const Color(0xFFFFECDE),
          ),
          const SizedBox(width: 10),
          _StatChip(
            icon: Icons.favorite_border_rounded,
            value: '12',
            label: 'Memories',
            bg: const Color(0xFFE4EFEA),
          ),
          const SizedBox(width: 10),
          _StatChip(
            icon: Icons.calendar_month_outlined,
            value: '24',
            label: 'Months left',
            bg: const Color(0xFFF0EBF8),
          ),
        ],
      );
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.bg,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: const Color(0xFF5E3A30)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF38251F),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF7A5E55), fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state hint ──────────────────────────────────────────────────────────

class _EmptyStateHint extends StatelessWidget {
  const _EmptyStateHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPeach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: _kBrown, size: 20),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start another capsule',
                    style: TextStyle(
                      color: _kDeep,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Preserve a new story for the future',
                    style: TextStyle(color: _kMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: Color(0xFFBBA9A2)),
          ],
        ),
      ),
    );
  }
}
