import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});
  static const mainItems = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Home'), (icon: Icons.explore_outlined, label: 'Explore Places'), (icon: Icons.forum_outlined, label: 'Q&A Forum'),
    (icon: Icons.inventory_2_outlined, label: 'Time capsule'), (icon: Icons.event_outlined, label: 'Latest Events'), (icon: Icons.search, label: 'Translation'), (icon: Icons.quiz_outlined, label: 'Quizzes'),
  ];
  static const savedItems = <({IconData icon, String label})>[
    (icon: Icons.bookmark_border, label: 'Saved posts'), (icon: Icons.favorite_border, label: 'Favourite places'),
    (icon: Icons.public, label: 'Created Time Capsules'), (icon: Icons.view_in_ar_outlined, label: 'Explore Things With 3D Map'),
  ];
  @override Widget build(BuildContext context) => Drawer(
    width: MediaQuery.sizeOf(context).width * .78, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(),
    child: SafeArea(child: Column(children: [
      Container(color: AppColors.brown, padding: const EdgeInsets.fromLTRB(16, 12, 10, 12), child: Row(children: [
        const CircleAvatar(radius: 25, backgroundColor: Color(0xFFFFD8BD), child: Icon(Icons.person, size: 31, color: AppColors.brown)), const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Amaya wikram', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)), Text('Colombo', style: TextStyle(color: Colors.white70, fontSize: 9)), Text('2.3k followers', style: TextStyle(color: Colors.white70, fontSize: 9))])),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 18, color: Colors.white70)),
      ])),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8), children: [
        const _SectionLabel('Main'),
        for (var i = 0; i < mainItems.length; i++) _DrawerItem(icon: mainItems[i].icon, label: mainItems[i].label, selected: i == 0, onTap: () { Navigator.pop(context); if (i == 0) { Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false); } else if (i == 1) { Navigator.pushReplacementNamed(context, '/explorer'); } }),
        const SizedBox(height: 8), const _SectionLabel('Saved'),
        for (var i = 0; i < savedItems.length; i++) _DrawerItem(icon: savedItems[i].icon, label: savedItems[i].label, onTap: () { Navigator.pop(context); if (i == 3) Navigator.pushNamed(context, '/province-map'); }),
      ])),
      const Divider(height: 1), Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Column(children: [
        _DrawerItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
        _DrawerItem(icon: Icons.logout, label: 'Log Out', onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)),
        const SizedBox(height: 4), const Text('2026 All Right Received\nV.2.1.1', textAlign: TextAlign.center, style: TextStyle(fontSize: 7, color: Colors.grey)),
      ])),
    ])),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text); final String text;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(8, 2, 8, 4), child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)));
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.selected = false});
  final IconData icon; final String label; final VoidCallback onTap; final bool selected;
  @override Widget build(BuildContext context) => ListTile(
    dense: true, visualDensity: const VisualDensity(vertical: -3), minLeadingWidth: 20,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), selected: selected, selectedTileColor: const Color(0xFFFFD9BE),
    leading: Icon(icon, size: 17, color: AppColors.brown), title: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.brown, fontWeight: FontWeight.w600)), onTap: onTap,
  );
}
