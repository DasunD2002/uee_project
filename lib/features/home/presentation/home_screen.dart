import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import 'widgets/home_drawer.dart';
import 'widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void selectTab(int index) {
    if (index == 1) Navigator.pushNamed(context, '/explorer');
    if (index == 3) Navigator.pushNamed(context, '/capsule');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F6F4),
    drawer: const HomeDrawer(selectedSection: 'Home'),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA),
      foregroundColor: AppColors.brown,
      centerTitle: true,
      elevation: 0,
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, size: 21),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(Icons.notifications_none, size: 22),
        ),
      ],
    ),
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _SearchBar(controller: searchController)),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(8, 2, 8, 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              StoryCard(
                category: 'Heritage Site',
                imagePath: 'assets/images/login_image.jpg',
                title: 'The frescoes hidden halfway up Sigiriya',
                location: 'Sigiriya Rock Fortress · Matale',
                description:
                    'My grandmother climbed Sigiriya in 1962, barefoot, with a tiffin of string hoppers tied to her waist...',
                likes: '1,284',
                comments: '96',
              ),
              SizedBox(height: 10),
              StoryCard(
                category: 'Craft',
                author: 'Dinesh',
                handle: '@dineshcarves',
                time: '5h',
                imagePath: 'assets/images/mask_carver.png',
                title: 'Ambalangoda mask carvers and the spirits they keep',
                location: 'Ambalangoda · Galle',
                description:
                    'For generations, local artisans have shaped stories and spirits from kaduru wood, keeping an ancient craft alive.',
                likes: '842',
                comments: '54',
              ),
            ]),
          ),
        ),
      ],
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 0,
      onSelected: selectTab,
    ),
  );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: const Color(0xFFF0EEEE),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: AppColors.brown,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}
