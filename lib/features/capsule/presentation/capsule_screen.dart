import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../domain/capsule_model.dart';
import '../data/capsule_service.dart';
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
class CapsuleScreen extends StatefulWidget {
  const CapsuleScreen({super.key});

  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  final CapsuleService _capsuleService = CapsuleService();
  List<CapsuleModel> _capsules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCapsules();
  }

  Future<void> _loadCapsules() async {
    setState(() => _isLoading = true);
    final list = await _capsuleService.getCapsules();
    if (!mounted) return;
    setState(() {
      _capsules = list;
      _isLoading = false;
    });
  }

  Future<void> _navigateToCreate() async {
    final res = await Navigator.pushNamed(context, '/create-capsule');
    if (res == true) {
      _loadCapsules();
    }
  }

  void _onNavSelected(BuildContext context, int index) {
    navigateToPrimaryDestination(context, index, currentIndex: 3);
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
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
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
              _StatRow(capsuleCount: _capsules.length),
              const SizedBox(height: 24),

              // ── Prompt / hero card ────────────────────────────────────────
              CapsulePromptCard(
                onCreate: _navigateToCreate,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kPeach,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDDB69E)),
                    ),
                    child: Text(
                      '${_capsules.length} protected',
                      style: const TextStyle(
                        color: _kBrown,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: _kBrown),
                  ),
                )
              else if (_capsules.isEmpty)
                _EmptyStateHint(onTap: _navigateToCreate)
              else ...[
                for (final c in _capsules) ...[
                  CapsuleTile(capsule: c, onRefresh: _loadCapsules),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 14),

              // ── Empty state hint ──────────────────────────────────────────
              _EmptyStateHint(
                onTap: _navigateToCreate,
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
  const _StatRow({this.capsuleCount = 1});
  final int capsuleCount;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _StatChip(
            icon: Icons.lock_clock_outlined,
            value: capsuleCount < 10 ? '0$capsuleCount' : '$capsuleCount',
            label: 'Capsules',
            bg: const Color(0xFFFFECDE),
          ),
          const SizedBox(width: 10),
          const _StatChip(
            icon: Icons.favorite_border_rounded,
            value: '12',
            label: 'Memories',
            bg: Color(0xFFE4EFEA),
          ),
          const SizedBox(width: 10),
          const _StatChip(
            icon: Icons.calendar_month_outlined,
            value: '24',
            label: 'Months left',
            bg: Color(0xFFF0EBF8),
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
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: _kBrown),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: _kDeep,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: _kMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Empty state dashed hint ───────────────────────────────────────────────────

class _EmptyStateHint extends StatelessWidget {
  const _EmptyStateHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDFCFC9),
              style: BorderStyle.solid,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: _kBrown, size: 16),
              SizedBox(width: 8),
              Text(
                'Seal another time capsule',
                style: TextStyle(
                  color: _kBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}
