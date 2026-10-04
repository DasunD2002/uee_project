import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../data/places_repository.dart';
import '../domain/place.dart';
import '../domain/province_details.dart';
import 'field_notes_archive_screen.dart';
import 'field_note_editor_screen.dart';
import 'widgets/explorer_footer.dart';
import 'widgets/province_source_button.dart';
import 'widgets/region_image.dart';

class ProvinceDetailScreen extends StatefulWidget {
  const ProvinceDetailScreen({
    super.key,
    required this.name,
    required this.tagline,
    required this.sites,
    required this.accentColor,
    this.repository,
  });

  final String name;
  final String tagline;
  final List<String> sites;
  final Color accentColor;
  final PlacesRepository? repository;

  String get provinceId =>
      name.replaceFirst(' Province', '').toLowerCase().replaceAll(' ', '-');

  @override
  State<ProvinceDetailScreen> createState() => _ProvinceDetailScreenState();
}

class _ProvinceDetailScreenState extends State<ProvinceDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  late final PlacesRepository _repository;
  late final bool _ownsRepository;
  ProvinceDetails? _details;
  List<Place> _places = [];
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  bool _retryMore = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PlacesRepository();
    _ownsRepository = widget.repository == null;
    _load();
  }

  @override
  void didUpdateWidget(covariant ProvinceDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provinceId != widget.provinceId) {
      _searchDebounce?.cancel();
      _searchController.clear();
      _details = null;
      _places = [];
      _load();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _load();
    });
  }

  void _submitSearch() {
    _searchDebounce?.cancel();
    FocusScope.of(context).unfocus();
    _load();
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    final request = ++_requestId;
    final page = more ? _details!.places.page + 1 : 0;
    setState(() {
      _error = null;
      _loading = !more;
      _loadingMore = more;
    });
    try {
      final result = await _repository.fetchProvince(
        widget.provinceId,
        query: _searchController.text,
        page: page,
      );
      if (!mounted || request != _requestId) return;
      setState(() {
        _details = result;
        final items = more
            ? [..._places, ...result.places.items]
            : result.places.items;
        _places = {for (final item in items) item.id: item}.values.toList();
        _loading = false;
        _loadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted || request != _requestId) return;
      setState(() {
        _error = error is PlacesApiException
            ? error.message
            : 'Could not load this province. Please try again.';
        _retryMore = more;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _showTradition(ProvinceTradition tradition) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tradition.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RegionImage(
                source: tradition.imageUrl,
                height: 150,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              Text(
                tradition.description ??
                    'No description is available from the source.',
              ),
              ProvinceSourceButton(
                sourceUrl: tradition.sourceUrl,
                imageSourceUrl: tradition.imageSourceUrl,
                wikipediaUrl: tradition.wikipediaUrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllTraditions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final tradition in _details!.traditions)
              ListTile(
                title: Text(tradition.name),
                subtitle: Text(
                  tradition.description ?? 'View tradition details',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showTradition(tradition);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const HomeDrawer(selectedSection: 'Explore Places'),
    backgroundColor: const Color(0xFFFFFDFC),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA),
      foregroundColor: AppColors.brown,
      centerTitle: true,
      leading: const RootlyBackButton(fallbackRoute: '/province-map'),
      title: const Text(
        'Rootly',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: const Icon(Icons.notifications_none, size: 21),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 26),
        children: [
          const _PageHeading(),
          const SizedBox(height: 28),
          if (_details == null) ...[
            Text(widget.name, style: _sectionTitle),
            const SizedBox(height: 24),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _LoadError(message: _error!, onRetry: _load),
          ] else
            ..._content(_details!),
        ],
      ),
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 1,
      onSelected: (index) => navigateToPrimaryDestination(context, index),
    ),
  );

  List<Widget> _content(ProvinceDetails details) {
    final province = details.province;
    final page = details.places;
    return [
      if (_loading) const LinearProgressIndicator(),
      _Hero(
        name: province.name,
        tagline: province.description ?? 'Sri Lanka',
        image: province.imageUrl ?? '',
      ),
      ProvinceSourceButton(
        sourceUrl: province.sourceUrl,
        imageSourceUrl: province.imageSourceUrl,
        wikipediaUrl: province.wikipediaUrl,
      ),
      if (page.stale || page.truncated)
        Text(
          [
            if (page.stale) 'Showing cached province data.',
            if (page.truncated)
              'Some places may be missing from these results.',
          ].join(' '),
          style: _bodyStyle,
        ),
      const SizedBox(height: 24),
      _InfoCard(
        title: 'Region at a Glance',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              province.overview.isEmpty
                  ? 'No overview is available from the source.'
                  : province.overview,
              style: _bodyStyle,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final district in province.districts)
                  _Tag(label: district),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _InfoCard(
        title: 'Visitor Essentials',
        child: Column(
          children: [
            _Essential(
              icon: Icons.location_city_outlined,
              title: 'Provincial Capital',
              value: province.capital ?? 'Not available from the source.',
            ),
            _Essential(
              icon: Icons.map_outlined,
              title: 'Districts',
              value: province.districts.isEmpty
                  ? 'Not available from the source.'
                  : province.districts.join(', '),
            ),
            const _Essential(
              icon: Icons.public,
              title: 'Country',
              value: 'Sri Lanka',
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      const Text('Top Heritage Sites', style: _sectionTitle),
      const SizedBox(height: 12),
      TextField(
        key: const Key('province-place-search'),
        controller: _searchController,
        maxLength: 120,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted: (_) => _submitSearch(),
        decoration: InputDecoration(
          hintText: 'Search places in ${province.name}',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear place search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                ),
          border: const OutlineInputBorder(),
          counterText: '',
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '${page.total} place${page.total == 1 ? '' : 's'} · ${page.source}',
        style: _bodyStyle,
      ),
      const SizedBox(height: 12),
      if (_places.isEmpty)
        _InfoCard(
          title: _searchController.text.trim().isEmpty
              ? 'No heritage sites found'
              : 'No matching places',
          child: Text(
            _searchController.text.trim().isEmpty
                ? 'The source has no heritage places linked to this province yet.'
                : 'No places match your search in this province.',
            style: _bodyStyle,
          ),
        ),
      for (final place in _places) ...[
        _HeritageCard(
          province: province.name,
          title: place.name,
          image: place.imageUrl ?? '',
          category: place.category.toUpperCase(),
          description:
              place.description ??
              'No description is available from the source.',
          sourceUrl: place.sourceUrl,
          imageSourceUrl: place.imageSourceUrl,
          wikipediaUrl: place.wikipediaUrl,
        ),
        const SizedBox(height: 16),
      ],
      if (_error != null)
        _LoadError(
          message: _error!,
          onRetry: () => _load(more: _retryMore),
        ),
      if (page.hasNext)
        OutlinedButton(
          onPressed: _loadingMore || _loading ? null : () => _load(more: true),
          child: _loadingMore
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Load more heritage sites'),
        ),
      Row(
        children: [
          const Expanded(
            child: Text('Cultural Traditions', style: _sectionTitle),
          ),
          TextButton(
            onPressed: details.traditions.isEmpty ? null : _showAllTraditions,
            child: const Text('View all →'),
          ),
        ],
      ),
      if (details.traditions.isEmpty)
        const Text(
          'No documented traditions are linked to this province in the source yet.',
          style: _bodyStyle,
        )
      else
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final tradition in details.traditions)
                _TraditionCard(
                  image: tradition.imageUrl ?? '',
                  title: tradition.name,
                  description:
                      tradition.description ?? 'View tradition details',
                  onTap: () => _showTradition(tradition),
                ),
            ],
          ),
        ),
    ];
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_outlined, color: AppColors.brown, size: 34),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center, style: _bodyStyle),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    ),
  );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading();
  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFFFEBDD),
      borderRadius: BorderRadius.circular(11),
    ),
    child: const Center(
      child: Text(
        'Explore Province',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.name, required this.tagline, required this.image});
  final String name, tagline, image;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: .92,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RegionImage(source: image),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xD9000000)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDCB8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    child: Text(
                      'REGION',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tagline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF8),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFFE8D8CF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.brown,
            fontFamily: 'serif',
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(height: 18, color: Color(0xFFD9C6BD)),
        child,
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFFFD9B8),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _Essential extends StatelessWidget {
  const _Essential({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.brown, size: 18),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HeritageCard extends StatelessWidget {
  const _HeritageCard({
    required this.province,
    required this.title,
    required this.image,
    required this.category,
    required this.description,
    this.sourceUrl,
    this.imageSourceUrl,
    this.wikipediaUrl,
  });
  final String province, title, image, category, description;
  final String? sourceUrl, imageSourceUrl, wikipediaUrl;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF8),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0xFFE8D8CF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: RegionImage(
              source: image,
              height: 155,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          category,
          style: const TextStyle(
            color: AppColors.brown,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: _bodyStyle,
        ),
        ProvinceSourceButton(
          sourceUrl: sourceUrl,
          imageSourceUrl: imageSourceUrl,
          wikipediaUrl: wikipediaUrl,
        ),
        const SizedBox(height: 13),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FieldNoteEditorScreen(
                province: province,
                initialSite: title,
                image: image,
              ),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brown,
            minimumSize: const Size.fromHeight(34),
            shape: const RoundedRectangleBorder(),
          ),
          child: const Text(
            'Create Field Notes',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 5),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FieldNotesArchiveScreen(
                province: province,
                site: title,
                image: image,
              ),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brown,
            minimumSize: const Size.fromHeight(34),
            shape: const RoundedRectangleBorder(),
          ),
          child: const Text(
            'View Field Notes',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _TraditionCard extends StatelessWidget {
  const _TraditionCard({
    required this.image,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final String image, title, description;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE8D8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            child: RegionImage(
              source: image,
              height: 125,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

const _sectionTitle = TextStyle(
  fontFamily: 'serif',
  fontSize: 22,
  fontWeight: FontWeight.bold,
);
const _bodyStyle = TextStyle(
  fontSize: 12,
  color: Color(0xFF655B57),
  height: 1.55,
);
