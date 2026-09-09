import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/capsule_prompt_card.dart';
import 'widgets/capsule_tile.dart';

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
    backgroundColor: const Color(0xFFFFFAF7),
    drawer: const HomeDrawer(),
    appBar: AppBar(
      toolbarHeight: 68,
      backgroundColor: const Color(0xFFFFF4F1),
      foregroundColor: AppColors.brown,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu_rounded, size: 20),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, size: 19),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your stories,\nbeautifully kept.',
            style: TextStyle(
              color: Color(0xFF39231B),
              fontSize: 30,
              height: .98,
              fontWeight: FontWeight.w700,
              letterSpacing: -.7,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Ayubowan, Kumari  ·  your legacy vault',
            style: TextStyle(
              color: Color(0xFF6B5D58),
              fontFamily: 'serif',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          CapsulePromptCard(
            onCreate: () => Navigator.pushNamed(context, '/create-capsule'),
          ),
          const SizedBox(height: 25),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR TIME CAPSULES',
                style: TextStyle(
                  color: Color(0xFF574640),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              Text(
                '1 protected',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const CapsuleTile(),
        ],
      ),
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 3,
      onSelected: (index) => _onNavSelected(context, index),
    ),
  );
}
