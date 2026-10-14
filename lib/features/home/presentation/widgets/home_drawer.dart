import 'package:flutter/material.dart';
import '../../../../core/localization/app_language_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../Profile/data/user_service.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key, this.selectedSection});
  final String? selectedSection;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await _userService.getUserProfile();
    if (mounted && profile != null) {
      setState(() {
        _userProfile = profile;
      });
    }
  }

  String? activeSection(BuildContext context) =>
      widget.selectedSection ??
      const {
        '/home': 'Home',
        '/explorer': 'Explore Places',
        '/profile': 'Profile',
        '/saved-posts': 'Saved posts',
        '/capsule': 'Time capsule',
        '/capsules': 'Time capsule',
        '/province-map': 'Explore Things With 3D Map',
        '/questions': 'Q&A Forum',
        '/question-detail': 'Q&A Forum',
        '/ask-question': 'Q&A Forum',
        '/translations': 'Translation',
        '/quizzes': 'Quizzes',
        '/daily-quiz': 'Quizzes',
      }[ModalRoute.of(context)?.settings.name];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentSection = activeSection(context);

    final mainItems = <({IconData icon, String key, String label})>[
      (icon: Icons.home_outlined, key: 'Home', label: l10n.drawerHome),
      (icon: Icons.explore_outlined, key: 'Explore Places', label: l10n.drawerExplorePlaces),
      (icon: Icons.forum_outlined, key: 'Q&A Forum', label: l10n.drawerQaForum),
      (icon: Icons.inventory_2_outlined, key: 'Time capsule', label: l10n.drawerTimeCapsule),
      (icon: Icons.event_outlined, key: 'Latest Events', label: l10n.drawerLatestEvents),
      (icon: Icons.search, key: 'Translation', label: l10n.drawerTranslation),
      (icon: Icons.quiz_outlined, key: 'Quizzes', label: l10n.drawerQuizzes),
    ];

    final savedItems = <({IconData icon, String key, String label})>[
      (icon: Icons.bookmark_border, key: 'Saved posts', label: l10n.drawerSavedPosts),
      (icon: Icons.favorite_border, key: 'Favourite places', label: l10n.drawerFavouritePlaces),
      (icon: Icons.public, key: 'Created Time Capsules', label: l10n.drawerCreatedTimeCapsules),
      (icon: Icons.view_in_ar_outlined, key: 'Explore Things With 3D Map', label: l10n.drawerExplore3dMap),
    ];

    return Drawer(
      width: MediaQuery.sizeOf(context).width * .78,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.brown,
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFFFD8BD),
                    backgroundImage: _userProfile?['photoUrl'] != null
                        ? NetworkImage(_userProfile!['photoUrl'])
                        : null,
                    child: _userProfile?['photoUrl'] == null
                        ? const Icon(Icons.person, size: 31, color: AppColors.brown)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userProfile?['name'] ?? l10n.loading,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _userProfile?['district'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                          Text(
                            l10n.drawerViewProfile,
                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                children: [
                  _SectionLabel(l10n.sectionMain),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: l10n.drawerProfile,
                    selected: currentSection == 'Profile' || currentSection == l10n.drawerProfile,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  for (var i = 0; i < mainItems.length; i++)
                    _DrawerItem(
                      icon: mainItems[i].icon,
                      label: mainItems[i].label,
                      selected: currentSection == mainItems[i].key || currentSection == mainItems[i].label,
                      onTap: () {
                        Navigator.pop(context);
                        if (i == 0) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (_) => false,
                          );
                        } else if (i == 1) {
                          Navigator.pushReplacementNamed(context, '/explorer');
                        } else if (i == 2) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/questions',
                            (_) => false,
                          );
                        } else if (i == 3) {
                          Navigator.pushNamed(context, '/capsules');
                        } else if (i == 5) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/translations',
                            (_) => false,
                          );
                        } else if (i == 6) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/quizzes',
                            (_) => false,
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 8),
                  _SectionLabel(l10n.sectionSaved),
                  for (var i = 0; i < savedItems.length; i++)
                    _DrawerItem(
                      icon: savedItems[i].icon,
                      label: savedItems[i].label,
                      selected: currentSection == savedItems[i].key || currentSection == savedItems[i].label,
                      onTap: () {
                        Navigator.pop(context);
                        if (i == 0) Navigator.pushNamed(context, '/saved-posts');
                        if (i == 3) Navigator.pushNamed(context, '/province-map');
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _DrawerItem(
                    icon: Icons.language,
                    label: '${l10n.drawerLanguage} (${AppLanguageProvider.instance.currentLanguage.nativeName})',
                    onTap: () {
                      Navigator.pop(context);
                      AppLanguageProvider.instance.showLanguageDialog(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: l10n.drawerSettings,
                    selected: currentSection == 'Settings' || currentSection == l10n.drawerSettings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: l10n.drawerLogOut,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.copyrightNotice,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 7, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    visualDensity: const VisualDensity(vertical: -3),
    minLeadingWidth: 20,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    selected: selected,
    selectedTileColor: const Color(0xFFFFD9BE),
    leading: Icon(icon, size: 17, color: AppColors.brown),
    title: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.brown,
        fontWeight: FontWeight.w600,
      ),
    ),
    onTap: onTap,
  );
}
