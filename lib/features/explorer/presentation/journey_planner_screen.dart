import 'package:flutter/material.dart';

import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../data/journey_store.dart';
import '../domain/journey.dart';
import '../domain/place.dart';
import 'widgets/explorer_footer.dart';
import 'widgets/place_image.dart';

class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({super.key, this.selectedPlace, this.store});

  final Place? selectedPlace;
  final JourneyStore? store;

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  late final JourneyStore store;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? JourneyStore.instance;
    if (widget.selectedPlace case final place?) store.addPlace(place);
  }

  void _addMoreSites() {
    final navigator = Navigator.of(context);
    var foundExplorer = false;
    navigator.popUntil((route) {
      foundExplorer = route.settings.name == '/explorer';
      return foundExplorer || route.isFirst;
    });
    if (!foundExplorer) navigator.pushReplacementNamed('/explorer');
  }

  Future<void> _chooseDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = store.date;
    final date = await showDatePicker(
      context: context,
      initialDate: selected ?? now,
      firstDate: selected != null && selected.isBefore(now) ? selected : now,
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (!mounted || date == null) return;
    store.setDate(date);
  }

  void _showRoute() {
    final sites = store.sites;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .65,
          minChildSize: .3,
          maxChildSize: .9,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                'Route preview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your stops in visit order. Travel times are not included.',
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < sites.length; index++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFD9BE),
                    foregroundColor: AppColors.brown,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(sites[index].place.name),
                  subtitle: Text(
                    '${sites[index].place.subtitle}\n'
                    '${sites[index].place.location.latitude.toStringAsFixed(4)}, '
                    '${sites[index].place.location.longitude.toStringAsFixed(4)}',
                  ),
                  isThreeLine: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final sites = store.sites;
      final timedStops = store.timedStops;
      return Scaffold(
        drawer: const HomeDrawer(selectedSection: 'Explore Places'),
        backgroundColor: const Color(0xFFF9F7F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFEAEA),
          foregroundColor: AppColors.brown,
          centerTitle: true,
          leading: const RootlyBackButton(fallbackRoute: '/explorer'),
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
              tooltip: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Icon(Icons.notifications_none, size: 20),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'JOURNEY BUILDER',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          color: AppColors.brown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoChip(
                            icon: Icons.route,
                            label:
                                '${sites.length} stop${sites.length == 1 ? '' : 's'}',
                          ),
                          _InfoChip(
                            icon: Icons.schedule,
                            label: timedStops == 0
                                ? 'Visit times not set'
                                : '${formatVisitMinutes(store.visitMinutes)} planned'
                                      '${timedStops < sites.length ? ' · $timedStops/${sites.length} stops timed' : ''}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: const Color(0xFFFFF1E9),
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.my_location,
                                color: AppColors.brown,
                              ),
                              title: const Text(
                                'Starting place',
                                style: TextStyle(fontSize: 11),
                              ),
                              subtitle: Text(
                                sites.isEmpty
                                    ? 'Add a place to start your journey'
                                    : sites.first.place.name,
                              ),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.brown,
                              ),
                              title: const Text(
                                'Journey date',
                                style: TextStyle(fontSize: 11),
                              ),
                              subtitle: Text(
                                store.date == null
                                    ? 'Choose a date'
                                    : MaterialLocalizations.of(
                                        context,
                                      ).formatFullDate(store.date!),
                              ),
                              onTap: _chooseDate,
                              trailing: store.date == null
                                  ? const Icon(Icons.chevron_right)
                                  : IconButton(
                                      tooltip: 'Clear journey date',
                                      onPressed: () => store.setDate(null),
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Itinerary',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.brown,
                        ),
                      ),
                      if (sites.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Drag the handle to reorder your stops.',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (sites.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.travel_explore,
                          size: 44,
                          color: AppColors.brown,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your journey starts here',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Find a place in Explore Places and tap Add to Journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverReorderableList(
                    itemCount: sites.length,
                    onReorderItem: store.reorder,
                    itemBuilder: (context, index) => _JourneySiteCard(
                      key: ValueKey(sites[index].place.id),
                      site: sites[index],
                      index: index,
                      onRemove: () => store.removePlace(sites[index].place.id),
                      onVisitTimeChanged: (minutes) =>
                          store.setVisitMinutes(sites[index].place.id, minutes),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _addMoreSites,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          sites.isEmpty ? 'Explore Places' : 'Add More Sites',
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: sites.isEmpty
                            ? null
                            : () {
                                if (!store.saveDraft()) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text('Journey draft saved.'),
                                    ),
                                  );
                              },
                        child: const Text('Save Draft'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JourneyDraftsScreen(store: store),
                          ),
                        ),
                        icon: const Icon(Icons.drafts_outlined, size: 18),
                        label: Text('View Drafts (${store.drafts.length})'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: sites.isEmpty ? null : _showRoute,
                        icon: const Icon(Icons.route_outlined, size: 18),
                        label: const Text('View Route'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ExplorerFooter(
          selectedIndex: 1,
          onSelected: (index) => navigateToPrimaryDestination(context, index),
        ),
      );
    },
  );
}

class _JourneySiteCard extends StatelessWidget {
  const _JourneySiteCard({
    super.key,
    required this.site,
    required this.index,
    required this.onRemove,
    required this.onVisitTimeChanged,
  });

  final JourneySite site;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<int?> onVisitTimeChanged;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFE5DEDA)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: PlaceImage(url: site.place.imageUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.place.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      site.place.name,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.place.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: 'Remove ${site.place.name}',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18, color: AppColors.brown),
              ),
            ],
          ),
          if (site.place.description case final description?) ...[
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Tooltip(
                  message: 'Drag to reorder stop ${index + 1}',
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.drag_indicator,
                          color: AppColors.brown,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${index + 1}',
                          style: const TextStyle(color: AppColors.brown),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                flex: 5,
                child: PopupMenuButton<int>(
                  tooltip: 'Set visit time for ${site.place.name}',
                  onSelected: (minutes) =>
                      onVisitTimeChanged(minutes == 0 ? null : minutes),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 0, child: Text('Not set')),
                    for (final minutes in [30, 45, 60, 90, 120, 180])
                      PopupMenuItem(
                        value: minutes,
                        child: Text(formatVisitMinutes(minutes)),
                      ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12,
                    ),
                    child: Text(
                      site.visitMinutes == null
                          ? 'Set visit time'
                          : formatVisitMinutes(site.visitMinutes!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF5E9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF427748)),
        const SizedBox(width: 5),
        Flexible(child: Text(label, style: const TextStyle(fontSize: 11))),
      ],
    ),
  );
}

class JourneyDraftsScreen extends StatelessWidget {
  const JourneyDraftsScreen({super.key, this.store});

  final JourneyStore? store;

  Future<void> _deleteDraft(
    BuildContext context,
    JourneyStore store,
    JourneyDraft draft,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete draft?'),
        content: Text('Remove "${draft.name}" from your drafts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) store.deleteDraft(draft);
  }

  @override
  Widget build(BuildContext context) {
    final journeyStore = store ?? JourneyStore.instance;
    return ListenableBuilder(
      listenable: journeyStore,
      builder: (context, _) {
        final drafts = journeyStore.drafts;
        return Scaffold(
          backgroundColor: const Color(0xFFF9F7F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFEAEA),
            foregroundColor: AppColors.brown,
            leading: const RootlyBackButton(fallbackRoute: '/journey'),
            title: const Text('Journey Drafts'),
          ),
          body: drafts.isEmpty
              ? const Center(child: Text('No saved drafts yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: drafts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final draft = drafts[index];
                    void openDraft() {
                      journeyStore.openDraft(draft);
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/journey'),
                            builder: (_) =>
                                JourneyPlannerScreen(store: journeyStore),
                          ),
                        );
                      }
                    }

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
                        subtitle: Text(
                          '${draft.sites.length} stop${draft.sites.length == 1 ? '' : 's'}'
                          '${draft.date == null ? '' : '\n${MaterialLocalizations.of(context).formatMediumDate(draft.date!)}'}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete draft',
                          onPressed: () =>
                              _deleteDraft(context, journeyStore, draft),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.brown,
                          ),
                        ),
                        onTap: openDraft,
                      ),
                    );
                  },
                ),
          bottomNavigationBar: ExplorerFooter(
            selectedIndex: 1,
            onSelected: (index) => navigateToPrimaryDestination(context, index),
          ),
        );
      },
    );
  }
}
