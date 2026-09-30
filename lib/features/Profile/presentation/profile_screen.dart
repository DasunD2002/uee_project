import '../domain/social_store.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../../core/widgets/community_app_bar.dart';
import '../../Post Creation/data/post_service.dart';
import '../../Post Creation/domain/user_post.dart';
import '../../Post Creation/presentation/create_post_screen.dart';
import '../../Post Creation/presentation/edit_post_screen.dart';
import '../../Post Creation/presentation/widgets/post_fields.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_post_card.dart';

// Keep this prototype's changes when navigating between profile and home.
final _posts = <UserPost>[
  UserPost(
    id: 'sigiriya',
    title: 'The frescoes hidden halfway up Sigiriya',
    story:
        'My grandmother climbed Sigiriya in 1962, barefoot, with a tiffin of string hoppers tied to her waist...',
    tags: ['sigiriya', 'frescoes', 'unesco', 'matale'],
  ),
  UserPost(
    id: 'craft',
    title: 'Ambalangoda mask carvers and the spirits they keep',
    story:
        'For generations, local artisans have shaped stories and spirits from kaduru wood, keeping an ancient craft alive.',
    category: 'Craft',
    place: 'Ambalangoda',
    district: 'Galle',
    asset: 'assets/images/mask_carver.png',
  ),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.showSavedPosts = false});
  final bool showSavedPosts;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool saved;
  @override
  void initState() {
    super.initState();
    saved = widget.showSavedPosts;
    SocialStore.instance.addListener(refreshCollections);
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final posts = saved 
        ? await PostService().getSavedPosts()
        : await PostService().getMyPosts();
    if (posts != null && mounted) {
      setState(() {
        _posts.clear();
        _posts.addAll(posts);
      });
    }
  }

  void refreshCollections() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SocialStore.instance.removeListener(refreshCollections);
    super.dispose();
  }

  Future<void> edit([UserPost? post]) async {
    final result = await Navigator.push<PostEditorResult>(
      context,
      MaterialPageRoute(
        builder: (_) => post == null
            ? const CreatePostScreen()
            : EditPostScreen(post: post),
      ),
    );
    if (result == null || !mounted) return;
    await _fetchPosts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.deleted
              ? 'Post deleted.'
              : result.post!.isDraft
              ? 'Draft saved. You can continue editing it from your profile.'
              : 'Post saved.',
        ),
      ),
    );
  }

  Future<void> createCollection() async {
    String name = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Create Collection'),
          content: TextField(
            autofocus: true,
            maxLength: 50,
            decoration: const InputDecoration(labelText: 'Collection name'),
            onChanged: (v) => update(() => name = v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: name.isEmpty
                  ? null
                  : () => Navigator.pop(context, name),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => SocialStore.instance.addCollection(result));
    }
  }

  void navigate(int index) {
    navigateToPrimaryDestination(context, index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    drawer: HomeDrawer(selectedSection: saved ? 'Saved posts' : 'Profile'),
    appBar: const CommunityAppBar(),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: null,
      onSelected: navigate,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            children: [
              ProfileHeader(
                postCount: _posts.where((p) => !p.isDraft).length,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 78,
                  vertical: 14,
                ),
                child: PostAction(
                  saved ? 'Create Collection' : 'Create Post',
                  onPressed: saved ? createCollection : edit,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(11, 6, 11, 18),
                child: Row(
                  children: [
                    for (final label in [
                      'Posts',
                      'Capsules',
                      'Saved posts',
                      'Quizzes',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 11),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: label == (saved ? 'Saved posts' : 'Posts'),
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: label == (saved ? 'Saved posts' : 'Posts')
                                ? Colors.white
                                : AppColors.brown,
                          ),
                          selectedColor: AppColors.brown,
                          backgroundColor: Colors.white,
                          shape: const StadiumBorder(
                            side: BorderSide(color: AppColors.brown),
                          ),
                          onSelected: (_) {
                            if (label == 'Capsules') {
                              Navigator.pushNamed(context, '/capsule');
                            } else if (label == 'Quizzes') {
                              Navigator.pushNamed(context, '/quizzes');
                            } else {
                              setState(() => saved = label == 'Saved posts');
                              _fetchPosts();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (_posts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    saved
                        ? 'Your saved stories will appear here.'
                        : 'Your stories will appear here. Create your first post.',
                  ),
                ),
              for (final post in _posts)
                ProfilePostCard(
                  key: ValueKey(post.id),
                  post: post,
                  onEdit: saved ? null : () => edit(post),
                  onDelete: saved ? null : () async {
                    final error = await PostService().deletePost(post.id);
                    if (!mounted) return;
                    if (error == null) {
                      _fetchPosts();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                ),

            ],
          ),
        ),
      ),
    ),
  );
}
