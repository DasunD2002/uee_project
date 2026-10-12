import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/capsule_prompt_card.dart';
import 'widgets/capsule_tile.dart';
import '../../capsules/data/capsule_store.dart';

// ── Local palette ─────────────────────────────────────────────────────────────
const _kBg = Color(0xFFFDF8F5);
const _kBrown = Color(0xFF84321F);
const _kDeep = Color(0xFF39231B);
const _kMuted = Color(0xFF6B5D58);
const _kBorder = Color(0xFFEEDFD9);
const _kPeach = Color(0xFFFFE8DA);

/// Dashboard reached from the Capsule item in the primary navigation.
class CapsuleScreen extends StatefulWidget {
  const CapsuleScreen({super.key});
  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  static String _monthsUntilUnlock(List<Map<String, dynamic>> capsules) {
    final dates =
        capsules
            .map(
              (capsule) => DateTime.tryParse(
                capsule['unlockCondition']?['date']?.toString() ?? '',
              ),
            )
            .whereType<DateTime>()
            .where((date) => date.isAfter(DateTime.now()))
            .toList()
          ..sort();
    return dates.isEmpty
        ? '—'
        : (dates.first.difference(DateTime.now()).inDays / 30)
              .ceil()
              .toString();
  }

  final store = CapsuleStore.instance;
  @override
  void initState() {
    super.initState();
    store.load();
  }

  Future<void> create() async {
    await Navigator.pushNamed(context, '/create-capsule');
    await store.load();
  }

  void _onNavSelected(BuildContext context, int index) {
    navigateToPrimaryDestination(context, index, currentIndex: 3);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
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
              'Your legacy vault',
              style: TextStyle(
                color: _kMuted,
                fontFamily: 'serif',
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 26),

            // ── Stat chips row ────────────────────────────────────────────
            _StatRow(
              count: store.capsules.length,
              memories: store.capsules.fold<int>(
                0,
                (sum, capsule) =>
                    sum + ((capsule['memoryCount'] as num?)?.toInt() ?? 0),
              ),
              months: _monthsUntilUnlock(store.capsules),
            ),
            const SizedBox(height: 24),

            // ── Prompt / hero card ────────────────────────────────────────
            CapsulePromptCard(onCreate: () => create()),
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
                  onTap: () => store.load(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _kPeach,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDDB69E)),
                    ),
                    child: Text(
                      '${store.capsules.length} protected',
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
            if (store.loading) const LinearProgressIndicator(),
            if (store.error != null)
              ListTile(
                title: Text(store.error!),
                trailing: TextButton(
                  onPressed: store.load,
                  child: const Text('Retry'),
                ),
              ),
            for (final capsule in store.capsules) CapsuleTile(capsule: capsule),
            const SizedBox(height: 14),

            // ── Empty state hint ──────────────────────────────────────────
            _EmptyStateHint(onTap: () => create()),
          ],
        ),
      ),
      bottomNavigationBar: ExplorerFooter(
        selectedIndex: 3,
        onSelected: (index) => _onNavSelected(context, index),
      ),
    ),
  );
}

// ── Stat chips ────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.count,
    required this.memories,
    required this.months,
  });
  final int count, memories;
  final String months;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _StatChip(
        icon: Icons.lock_clock_outlined,
        value: count.toString().padLeft(2, '0'),
        label: 'Capsules',
        bg: const Color(0xFFFFECDE),
      ),
      const SizedBox(width: 10),
      _StatChip(
        icon: Icons.favorite_border_rounded,
        value: memories.toString(),
        label: 'Memories',
        bg: const Color(0xFFE4EFEA),
      ),
      const SizedBox(width: 10),
      _StatChip(
        icon: Icons.calendar_month_outlined,
        value: months,
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
              style: const TextStyle(color: Color(0xFF7A5E55), fontSize: 9.5),
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
              child: const Icon(Icons.add_rounded, color: _kBrown, size: 20),
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
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFFBBA9A2),
            ),
          ],
        ),
      ),
    );
  }
}
