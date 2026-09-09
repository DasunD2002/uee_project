import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExplorerFooter extends StatelessWidget {
  const ExplorerFooter({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.explore_outlined, label: 'Explore'),
    (icon: Icons.forum_outlined, label: 'Questions'),
    (icon: Icons.view_in_ar_outlined, label: 'Capsule'),
  ];

  @override
  Widget build(BuildContext context) => selectedIndex == null
      ? Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: Semantics(
                        selected: false,
                        button: true,
                        child: InkWell(
                          onTap: () => onSelected(i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                items[i].icon,
                                color: AppColors.brown,
                                size: 19,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                items[i].label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
      : NavigationBar(
          height: 62,
          selectedIndex: selectedIndex!,
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
