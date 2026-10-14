import '../domain/social_store.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/primary_navigation.dart';
import '../../../../core/widgets/community_app_bar.dart';
import '../../Post Creation/data/post_service.dart';
import '../../Post Creation/domain/user_post.dart';
import '../../Post Creation/presentation/create_post_screen.dart';
import '../../Post Creation/presentation/edit_post_screen.dart';
import '../../Post Creation/presentation/widgets/post_fields.dart';
import '../../explorer/presentation/widgets/explorer_footer.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.showSavedPosts = false});
  final bool showSavedPosts;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _posts = <UserPost>[];
  late bool saved;
  @override
  void initState() {
    super.initState();
    saved = widget.showSavedPosts;
    SocialStore.instance.addListener(refreshCollections);
    SocialStore.instance.load().catchError((Object error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });
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
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.deleted
              ? l10n.postDeleted
              : result.post!.isDraft
              ? l10n.draftSaved
              : l10n.postSaved,
        ),
      ),
    );
  }

  Future<void> createCollection() async {
    final l10n = AppLocalizations.of(context);
    String name = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(l10n.createCollection),
          content: TextField(
            autofocus: true,
            maxLength: 50,
            decoration: InputDecoration(labelText: l10n.collectionName),
            onChanged: (v) => update(() => name = v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: name.isEmpty
                  ? null
                  : () => Navigator.pop(context, name),
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      try {
        SocialStore.instance.addCollection(result);
        await SocialStore.instance.flush();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void navigate(int index) {
    navigateToPrimaryDestination(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = [
      (key: 'Posts', label: l10n.postsLabel),
      (key: 'Capsules', label: l10n.navCapsule),
      (key: 'Saved posts', label: l10n.drawerSavedPosts),
      (key: 'Quizzes', label: l10n.drawerQuizzes),
    ];

    return Scaffold(
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
                    saved
                        ? l10n.createCollection
                        : (l10n.language == AppLanguage.sinhala
                            ? 'සටහනක් සාදන්න'
                            : (l10n.language == AppLanguage.tamil
                                ? 'பதிவை உருவாக்கு'
                                : 'Create Post')),
                    onPressed: saved ? createCollection : edit,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(11, 6, 11, 18),
                  child: Row(
                    children: [
                      for (final chip in chips)
                        Padding(
                          padding: const EdgeInsets.only(right: 11),
                          child: ChoiceChip(
                            label: Text(chip.label),
                            selected: chip.key == (saved ? 'Saved posts' : 'Posts'),
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: chip.key == (saved ? 'Saved posts' : 'Posts')
                                  ? Colors.white
                                  : AppColors.brown,
                            ),
                            selectedColor: AppColors.brown,
                            backgroundColor: Colors.white,
                            shape: const StadiumBorder(
                              side: BorderSide(color: AppColors.brown),
                            ),
                            onSelected: (_) {
                              if (chip.key == 'Capsules') {
                                Navigator.pushNamed(context, '/capsule');
                              } else if (chip.key == 'Quizzes') {
                                Navigator.pushNamed(context, '/quizzes');
                              } else {
                                setState(() => saved = chip.key == 'Saved posts');
                                _fetchPosts();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                if (saved)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${SocialStore.instance.collections.length} collections · ${SocialStore.instance.collections.fold<int>(0, (sum, collection) => sum + collection.count)} saved stories',
                        ),
                        for (final collection in SocialStore.instance.collections)
                          ExpansionTile(
                            title: Text(collection.name),
                            subtitle: Text('${collection.count} stories'),
                            children: [
                              for (final story in collection.stories.values)
                                ListTile(
                                  title: Text(story.title),
                                  subtitle: Text(story.author),
                                ),
                              if (collection.stories.isEmpty)
                                const ListTile(
                                  title: Text(
                                    'No stories saved to this collection yet.',
                                  ),
                                ),
                            ],
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
                    onDelete: saved
                        ? null
                        : () async {
                            final error = await PostService().deletePost(post.id);
                            if (!context.mounted) return;
                            if (error == null) {
                              _fetchPosts();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Post deleted')),
                              );
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
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
}
