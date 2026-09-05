import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExplorerFooter extends StatelessWidget {
  const ExplorerFooter({super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.explore_outlined, label: 'Explore'),
    (icon: Icons.forum_outlined, label: 'Questions'),
    (icon: Icons.view_in_ar_outlined, label: 'Capsule'),
  ];

  @override
  Widget build(BuildContext context) => NavigationBar(
    height: 62,
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    backgroundColor: Colors.white,
    indicatorColor: const Color(0xFFFFD9BE),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    destinations: [
      for (final item in items)
        NavigationDestination(
          icon: Icon(item.icon, color: AppColors.brown, size: 19),
          label: item.label,
        ),
    ],
  );
}
