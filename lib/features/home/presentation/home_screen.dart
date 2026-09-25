import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../Post Creation/data/post_service.dart';
import '../../Post Creation/domain/user_post.dart';
import 'widgets/home_drawer.dart';
import 'widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  List<UserPost>? _posts;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final posts = await PostService().getAllPosts();
    if (mounted) setState(() => _posts = posts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void selectTab(int index) {
    navigateToPrimaryDestination(context, index, currentIndex: 0);
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
        if (_posts == null)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_posts!.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('No posts yet.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _posts![index];
                  return Column(
                    children: [
                      StoryCard(
                        postId: post.id,
                        category: post.category.isEmpty ? 'General' : post.category,
                        imagePath: post.asset.isEmpty ? 'assets/images/login_image.jpg' : post.asset,
                        title: post.title,
                        location: '${post.place} · ${post.district}',
                        description: post.story,
                        likes: post.likeCount.toString(),
                        comments: post.commentCount.toString(),
                        author: post.authorName,
                        handle: post.authorHandle,
                        time: post.createdAt != null 
                            ? '${DateTime.now().difference(post.createdAt!).inHours}h'
                            : 'now',
                        postComments: post.comments,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
                childCount: _posts!.length,
              ),
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
