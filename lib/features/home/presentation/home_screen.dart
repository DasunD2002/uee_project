import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/home_drawer.dart';
import 'widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final searchController = TextEditingController();
  static const navigationItems = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Home'), (icon: Icons.map_outlined, label: 'Explore'),
    (icon: Icons.forum_outlined, label: 'Questions'), (icon: Icons.view_in_ar_outlined, label: 'Capsule'),
  ];
  @override void dispose() { searchController.dispose(); super.dispose(); }
  void selectTab(int index) {
    setState(() => selectedIndex = index);
    if (index == 1) Navigator.pushNamed(context, '/explorer');
    if (index == 3) Navigator.pushNamed(context, '/province-map');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F6F4), drawer: const HomeDrawer(),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA), foregroundColor: AppColors.brown, centerTitle: true, elevation: 0,
      title: const Text('Rootly', style: TextStyle(fontFamily: 'serif', fontSize: 25, fontWeight: FontWeight.bold)),
      leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, size: 21), onPressed: () => Scaffold.of(context).openDrawer())),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 22))],
    ),
    body: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _SearchBar(controller: searchController)),
      const SliverPadding(padding: EdgeInsets.fromLTRB(8, 2, 8, 12), sliver: SliverList(delegate: SliverChildListDelegate.fixed([
        StoryCard(category: 'Heritage Site', imagePath: 'assets/images/login_image.jpg', title: 'The frescoes hidden halfway up Sigiriya', location: 'Sigiriya Rock Fortress · Matale', description: 'My grandmother climbed Sigiriya in 1962, barefoot, with a tiffin of string hoppers tied to her waist...', likes: '1,284', comments: '96'),
        SizedBox(height: 10),
        StoryCard(category: 'Craft', imagePath: 'assets/images/mask_carver.png', title: 'Ambalangoda mask carvers and the spirits they keep', location: 'Ambalangoda · Galle', description: 'For generations, local artisans have shaped stories and spirits from kaduru wood, keeping an ancient craft alive.', likes: '842', comments: '54'),
      ]))),
    ]),
    bottomNavigationBar: NavigationBar(
      height: 64, selectedIndex: selectedIndex, onDestinationSelected: selectTab, backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFFFD9BE), labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [for (final item in navigationItems) NavigationDestination(icon: Icon(item.icon, color: AppColors.brown, size: 20), label: item.label)],
    ),
  );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 7), child: Row(children: [
      Expanded(child: SizedBox(height: 38, child: TextField(controller: controller, decoration: InputDecoration(hintText: 'Search...', hintStyle: const TextStyle(fontSize: 12), prefixIcon: const Icon(Icons.search, size: 18), filled: true, fillColor: const Color(0xFFF0EEEE), contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none))))),
      const SizedBox(width: 7), Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: IconButton(padding: EdgeInsets.zero, onPressed: () {}, icon: const Icon(Icons.filter_alt_outlined, color: AppColors.brown, size: 20))),
    ]),
  );
}
