import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_drawer.dart';

class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({
    super.key,
    this.selectedTitle,
    this.selectedImagePath,
    this.initialSites,
  });

  final String? selectedTitle;
  final String? selectedImagePath;
  final List<JourneySite>? initialSites;

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  late final List<JourneySite> sites;

  @override
  void initState() {
    super.initState();
    final store = JourneyStore.instance;
    if (widget.initialSites != null) {
      store.replaceSites(widget.initialSites!);
    } else {
      store.initializeDefaults();
    }
    sites = store.sites;

    if (widget.selectedTitle != null &&
        !sites.any((site) => site.title == widget.selectedTitle)) {
      sites.add(
        JourneySite(
          title: widget.selectedTitle!,
          description: 'Renowned for its massive, sublime Buddha statues carved directly into a granite cliff.',
          duration: '1.0 hrs',
          imagePath: widget.selectedImagePath ?? 'assets/images/gal_vihara.png',
        ),
      );
    }
  }

  static List<JourneySite> defaultSites() => [
      const JourneySite(
        title: 'Royal Palace of King Parakramabahu',
        description: 'The magnificent seven-storey palace ruins, showcasing the architectural grandeur.',
        duration: '1.5 hrs',
        imagePath: 'assets/images/login_image.jpg',
      ),
      const JourneySite(
        title: 'The Quadrangle (Dalada Maluva)',
        description: 'A compact group of fascinating ruins, including the circular Vatadage.',
        duration: '2.5 hrs',
        imagePath: 'assets/images/login_image.jpg',
      ),
      const JourneySite(
        title: 'Polonnaruwa Vatadage',
        description: 'An elegant circular relic house decorated with finely carved stone guardstones.',
        duration: '45 mins',
        imagePath: 'assets/images/gal_vihara.png',
      ),
      const JourneySite(
        title: 'Rankoth Vehera',
        description: 'The largest stupa in Polonnaruwa and an enduring landmark of the ancient city.',
        duration: '40 mins',
        imagePath: 'assets/images/login_image.jpg',
      ),
      const JourneySite(
        title: 'Lankatilaka Image House',
        description: 'A monumental brick shrine containing the remains of a towering Buddha image.',
        duration: '50 mins',
        imagePath: 'assets/images/gal_vihara.png',
      ),
    ];

  void reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final site = sites.removeAt(oldIndex);
      sites.insert(newIndex, site);
    });
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const HomeDrawer(),
    backgroundColor: const Color(0xFFF9F7F5),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA),
      foregroundColor: AppColors.brown,
      centerTitle: true,
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, size: 20),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Heritage Guide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'JOURNEY BUILDER',
              style: TextStyle(fontSize: 8, letterSpacing: 1.3),
            ),
            const SizedBox(height: 4),
            const Text(
              'One Day in Polonnaruwa',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 7,
              children: [
                _InfoChip(icon: Icons.calendar_today_outlined, label: '1 Ancient City'),
                _InfoChip(icon: Icons.schedule, label: 'About 5 hours'),
              ],
            ),
            const SizedBox(height: 12),
            const _JourneyInfo(),
            const SizedBox(height: 13),
            Row(
              children: [
                const Text(
                  'Itinerary',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text('${sites.length} stops on route', style: const TextStyle(fontSize: 9)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: sites.length,
                onReorder: reorder,
                proxyDecorator: (child, _, animation) => Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(7),
                  child: child,
                ),
                itemBuilder: (context, index) => _JourneySiteCard(
                  key: ValueKey(sites[index].title),
                  site: sites[index],
                  index: index,
                  onRemove: () => setState(() => sites.removeAt(index)),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.popUntil(
                context,
                (route) => route.settings.name == '/explorer',
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add More Sites'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brown,
                side: const BorderSide(color: Color(0xFFD6B5A8)),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                JourneyStore.instance.saveDraft();
                showMessage('Journey draft saved.');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brown,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Save Draft'),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JourneyDraftsScreen()),
              ),
              icon: const Icon(Icons.drafts_outlined, size: 16),
              label: const Text('View Drafts'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brown,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: () => showMessage('Route is ready to view.'),
              icon: const Icon(Icons.map_outlined, size: 16),
              label: const Text('View Route'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brown,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _JourneyInfo extends StatelessWidget {
  const _JourneyInfo();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1E9),
      borderRadius: BorderRadius.circular(7),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Starting Location', style: TextStyle(fontSize: 9, color: Colors.grey)),
        SizedBox(height: 4),
        Row(children: [Icon(Icons.my_location, size: 14, color: AppColors.brown), SizedBox(width: 5), Text('Polonnaruwa Roundabout Hotel', style: TextStyle(fontSize: 10))]),
        Divider(height: 18),
        Text('Journey Date', style: TextStyle(fontSize: 9, color: Colors.grey)),
        SizedBox(height: 4),
        Row(children: [Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.brown), SizedBox(width: 5), Text('Friday 24th May', style: TextStyle(fontSize: 10))]),
      ],
    ),
  );
}

class _JourneySiteCard extends StatelessWidget {
  const _JourneySiteCard({
    super.key,
    required this.site,
    required this.index,
    required this.onRemove,
  });
  final JourneySite site;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.brown),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.drag_indicator, size: 18, color: AppColors.brown),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFFE5DEDA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(site.imagePath, width: 92, height: 66, fit: BoxFit.cover),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(site.title, style: const TextStyle(fontFamily: 'serif', fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(site.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.black54, height: 1.3)),
                      const SizedBox(height: 6),
                      Text('◷ ${site.duration}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove site',
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.brown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFEAF5E9), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: Colors.green), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 8))]),
  );
}

class JourneySite {
  const JourneySite({required this.title, required this.description, required this.duration, required this.imagePath});
  final String title, description, duration, imagePath;
}

class JourneyDraft {
  const JourneyDraft({required this.name, required this.sites});
  final String name;
  final List<JourneySite> sites;
}

class JourneyStore {
  JourneyStore._();
  static final instance = JourneyStore._();

  final List<JourneySite> sites = [];
  final List<JourneyDraft> drafts = [];
  bool _initialized = false;

  void initializeDefaults() {
    if (_initialized) return;
    sites.addAll(_JourneyPlannerScreenState.defaultSites());
    _initialized = true;
  }

  void replaceSites(List<JourneySite> newSites) {
    sites
      ..clear()
      ..addAll(newSites);
    _initialized = true;
  }

  void saveDraft() {
    if (sites.isEmpty) return;
    drafts.insert(
      0,
      JourneyDraft(
        name: 'One Day in Polonnaruwa',
        sites: List<JourneySite>.from(sites),
      ),
    );
  }
}

class JourneyDraftsScreen extends StatefulWidget {
  const JourneyDraftsScreen({super.key});

  @override
  State<JourneyDraftsScreen> createState() => _JourneyDraftsScreenState();
}

class _JourneyDraftsScreenState extends State<JourneyDraftsScreen> {
  void openDraft(JourneyDraft draft) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JourneyPlannerScreen(
          initialSites: List<JourneySite>.from(draft.sites),
        ),
      ),
    );
  }

  Future<void> deleteDraft(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete draft?'),
        content: const Text(
          'This draft will be permanently removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => JourneyStore.instance.drafts.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Draft deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    final drafts = JourneyStore.instance.drafts;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEAEA),
        foregroundColor: AppColors.brown,
        title: const Text('Journey Drafts'),
      ),
      body: drafts.isEmpty
          ? const Center(child: Text('No saved drafts yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final draft = drafts[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFD9BE),
                      child: Icon(Icons.route, color: AppColors.brown),
                    ),
                    title: Text(
                      draft.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${draft.sites.length} stops'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => openDraft(draft),
                          tooltip: 'Edit draft',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.brown,
                          ),
                        ),
                        IconButton(
                          onPressed: () => deleteDraft(index),
                          tooltip: 'Delete draft',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => openDraft(draft),
                  ),
                );
              },
            ),
    );
  }
}
