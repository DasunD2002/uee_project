import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';

class CapsuleHomeScreen extends StatelessWidget {
  const CapsuleHomeScreen({super.key});

  void _navigate(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F5F2),
    drawer: const HomeDrawer(selectedSection: 'Time capsule'),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF8F5F2),
      foregroundColor: const Color(0xFF4A281E),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (scaffoldContext) => IconButton(
          onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
      ),
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          color: Color(0xFF4A281E),
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 21),
          ),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const Text(
          'Your stories deserve\na future.',
          style: TextStyle(
            color: Color(0xFF30201C),
            fontSize: 27,
            height: 1.04,
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Build a legacy your loved ones can open someday.',
          style: TextStyle(color: Color(0xFF766863), fontSize: 11),
        ),
        const SizedBox(height: 20),
        _StoryHero(
          onCreate: () => Navigator.pushNamed(context, '/create-capsule'),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.lock_clock_outlined, value: '01', label: 'CAPSULES', color: Color(0xFFFFE8DA))),
            SizedBox(width: 10),
            Expanded(child: _StatCard(icon: Icons.favorite_border_rounded, value: '12', label: 'MEMORIES', color: Color(0xFFE3EEE8))),
            SizedBox(width: 10),
            Expanded(child: _StatCard(icon: Icons.calendar_month_outlined, value: '24', label: 'MONTHS', color: Color(0xFFE9E3F2))),
          ],
        ),
        const SizedBox(height: 25),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('YOUR TIME CAPSULES', style: TextStyle(color: Color(0xFF5C4B45), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .6)),
            Text('View all', style: TextStyle(color: AppColors.brown, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 11),
        const _CapsuleCard(),
      ],
    ),
    bottomNavigationBar: ExplorerFooter(selectedIndex: 3, onSelected: (index) => _navigate(context, index)),
  );
}

class _StoryHero extends StatelessWidget {
  const _StoryHero({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    height: 250,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Color(0x263A2118), blurRadius: 22, offset: Offset(0, 11))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_image.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x001B100D), Color(0xDD29120B)],
                stops: [.25, 1],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xE8FFF8F3), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.brown, size: 13),
                  SizedBox(width: 5),
                  Text('ROOTLY MOMENTS', style: TextStyle(color: AppColors.brown, fontSize: 8, letterSpacing: .5, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 17,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Make today\nworth remembering.', style: TextStyle(color: Colors.white, fontSize: 22, height: 1.02, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 43,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF7F2),
                      foregroundColor: const Color(0xFF4F281B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 17),
                        SizedBox(width: 8),
                        Text('Create a new capsule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF5E4035), size: 17),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(color: Color(0xFF38251F), fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF715E55), fontSize: 7, fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _CapsuleCard extends StatelessWidget {
  const _CapsuleCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x0C3B241D), blurRadius: 15, offset: Offset(0, 6))],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset('assets/images/gal_vihara.png', width: 48, height: 48, fit: BoxFit.cover),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.brown), SizedBox(width: 4), Text('LOCKED', style: TextStyle(color: AppColors.brown, fontSize: 8, fontWeight: FontWeight.w800))]),
              SizedBox(height: 5),
              Text('Family Recipes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Opens on 12 April 2026', style: TextStyle(color: Color(0xFF877974), fontSize: 9)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF927B70), size: 15),
      ],
    ),
  );
}
