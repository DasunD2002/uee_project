import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../Post Creation/data/post_service.dart';
import '../../Post Creation/domain/user_post.dart';
import '../../Profile/data/user_service.dart';
import '../../Profile/domain/social_store.dart';
import 'widgets/home_drawer.dart';
import 'widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  List<UserPost>? _allPosts;
  List<UserPost>? _posts;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    SocialStore.instance.load().catchError((Object error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });
    _fetchPosts();
  }

  void _onSearchChanged() {
    if (searchController.text.isEmpty) {
      _applySearch();
    }
  }

  void _applySearch() {
    if (_allPosts == null) return;
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _posts = _allPosts);
      return;
    }
    setState(() {
      _posts = _allPosts!.where((post) {
        final title = post.title.toLowerCase();
        final place = post.place.toLowerCase();
        final district = post.district.toLowerCase();
        final author = post.authorName.toLowerCase();
        return title.contains(query) ||
            place.contains(query) ||
            district.contains(query) ||
            author.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchPosts() async {
    UserService().getUserProfile().then((_) {
      if (mounted) setState(() {});
    });
    final posts = await PostService().getAllPosts();
    if (mounted) {
      _allPosts = posts;
      _applySearch();
    }
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
        ListenableBuilder(
          listenable: SocialStore.instance,
          builder: (context, _) {
            final count = SocialStore.instance.unreadNotificationCount;
            final icon = const Icon(Icons.notifications_none, size: 22);
            return IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: count > 0
                  ? Badge(label: Text(count.toString()), child: icon)
                  : icon,
            );
          },
        ),
      ],
    ),
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _SearchBar(
            controller: searchController,
            onFilterPressed: _applySearch,
          ),
        ),
        if (_posts == null)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_posts!.isEmpty)
          const SliverFillRemaining(child: Center(child: Text('No posts yet.')))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = _posts![index];
                return Column(
                  children: [
                    StoryCard(
                      postId: post.id,
                      category: post.category.isEmpty
                          ? 'General'
                          : post.category,
                      imagePath: post.asset.isEmpty
                          ? 'assets/images/login_image.jpg'
                          : post.asset,
                      title: post.title,
                      location: '${post.place} · ${post.district}',
                      description: post.story,
                      likes: post.likeCount.toString(),
                      comments: post.commentCount.toString(),
                      author: post.authorName,
                      handle: post.authorHandle,
                      authorId: post.authorId,
                      authorPhoto: post.authorPhoto,
                      time: post.createdAt != null
                          ? '${DateTime.now().difference(post.createdAt!).inHours}h'
                          : 'now',
                      postComments: post.comments,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }, childCount: _posts!.length),
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
  const _SearchBar({required this.controller, required this.onFilterPressed});
  final TextEditingController controller;
  final VoidCallback onFilterPressed;
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
              onSubmitted: (_) => onFilterPressed(),
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
            onPressed: onFilterPressed,
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
