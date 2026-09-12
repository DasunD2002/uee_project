import '../domain/social_store.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/community_app_bar.dart';
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
final _collections = SocialStore.instance.collections;

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
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post?.id);
      if (result.deleted) {
        if (index >= 0) _posts.removeAt(index);
      } else if (result.post != null) {
        if (index >= 0) {
          _posts[index] = result.post!;
        } else {
          _posts.insert(0, result.post!);
        }
      }
    });
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
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
    if (index == 1) Navigator.pushNamed(context, '/explorer');
    if (index == 3) Navigator.pushNamed(context, '/capsule');
    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Questions are not available yet.')),
      );
    }
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
                postCount: 46 + _posts.where((p) => !p.isDraft).length,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Quizzes are not available yet.',
                                  ),
                                ),
                              );
                            } else {
                              setState(() => saved = label == 'Saved posts');
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (!saved) ...[
                if (_posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Your stories will appear here. Create your first post.',
                    ),
                  ),
                for (final post in _posts)
                  ProfilePostCard(
                    key: ValueKey(post.id),
                    post: post,
                    onEdit: () => edit(post),
                  ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(19, 0, 19, 16),
                  child: Text(
                    '${_collections.length} collections · ${_collections.fold<int>(0, (sum, c) => sum + c.count)} saved stories',
                    style: const TextStyle(color: Color(0xFF95857F)),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 13,
                    crossAxisSpacing: 13,
                    mainAxisExtent: 180,
                  ),
                  itemCount: _collections.length,
                  itemBuilder: (context, index) {
                    final collection = _collections[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      color: Colors.white,
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                        side: const BorderSide(color: Color(0xFFF0DDD4)),
                      ),
                      child: InkWell(
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(28),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    collection.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    collection.count == 0
                                        ? 'No stories saved in this collection yet.'
                                        : '${collection.count} saved stories · Preview collection',
                                  ),
                                  for (final story in collection.stories.values)
                                    ListTile(
                                      title: Text(story.title),
                                      subtitle: Text(story.author),
                                      onTap: () => showDialog<void>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(story.title),
                                          content: SingleChildScrollView(
                                            child: Text(story.description),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/${collection.image}.png',
                              height: 112,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 11, 8, 5),
                              child: Text(
                                collection.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                '${collection.count} stories',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF95857F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
