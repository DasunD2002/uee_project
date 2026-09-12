import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/places_repository.dart';
import '../domain/explore_category.dart';
import '../domain/place.dart';
import '../domain/places_page.dart';
import 'place_detail_screen.dart';
import 'widgets/place_image.dart';

class RedesignedExplorerScreen extends StatefulWidget {
  const RedesignedExplorerScreen({
    super.key,
    required this.onOpenDrawer,
    required this.repository,
  });

  final VoidCallback onOpenDrawer;
  final PlacesRepository repository;

  @override
  State<RedesignedExplorerScreen> createState() =>
      _RedesignedExplorerScreenState();
}

class _RedesignedExplorerScreenState extends State<RedesignedExplorerScreen> {
  static const _fallbackCategories = <ExploreCategory>[
    ExploreCategory(id: 'ancient-ruins', label: 'Ancient Ruins'),
    ExploreCategory(id: 'sacred-sites', label: 'Sacred Sites'),
    ExploreCategory(id: 'museums', label: 'Museums'),
    ExploreCategory(id: 'heritage-sites', label: 'Heritage Sites'),
  ];

  final _searchController = TextEditingController();
  List<ExploreCategory> _categories = const [];
  List<Place> _places = const [];
  String _selectedCategory = 'all';
  String? _errorMessage;
  String _source = '';
  int _page = 0;
  int _total = 0;
  int _requestId = 0;
  bool _hasNext = false;
  bool _stale = false;
  bool _truncated = false;
  bool _loading = true;
  bool _loadingMore = false;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCategories());
    unawaited(_loadPlaces());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.repository.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _categories = _fallbackCategories;
        _loadingCategories = false;
      });
    }
  }

  Future<void> _loadPlaces({bool reset = true, bool remember = false}) async {
    final requestId = ++_requestId;
    final requestedPage = reset ? 0 : _page + 1;
    setState(() {
      if (reset) {
        _loading = true;
        _errorMessage = null;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final result = await widget.repository.fetchPlaces(
        query: _searchController.text,
        category: _selectedCategory,
        page: requestedPage,
        size: 10,
        remember: remember,
      );
      if (!mounted || requestId != _requestId) return;
      _applyResult(result, reset: reset);
    } on Object catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _errorMessage = _messageFor(error);
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _applyResult(PlacesPage result, {required bool reset}) {
    setState(() {
      _places = reset ? result.items : [..._places, ...result.items];
      _page = result.page;
      _total = result.total;
      _hasNext = result.hasNext;
      _source = result.source;
      _stale = result.stale;
      _truncated = result.truncated;
      _errorMessage = null;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _submit(String value) async {
    FocusScope.of(context).unfocus();
    await _loadPlaces(remember: value.trim().isNotEmpty);
  }

  Future<void> _selectCategory(String category) async {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    await _loadPlaces();
  }

  String _messageFor(Object error) {
    if (error is PlacesApiException) return error.message;
    return 'Could not load Explore Places. Please try again.';
  }

  void _openPlace(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: RefreshIndicator(
      onRefresh: () => _loadPlaces(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFFFEAEA),
            foregroundColor: AppColors.brown,
            centerTitle: true,
            leading: IconButton(
              onPressed: widget.onOpenDrawer,
              icon: const Icon(Icons.menu, size: 20),
            ),
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
                tooltip: 'Journey Builder',
                onPressed: () => Navigator.pushNamed(context, '/journey'),
                icon: const Icon(Icons.route_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
                icon: const Icon(Icons.notifications_none, size: 20),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _ExplorerSearch(
                  controller: _searchController,
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 10),
                _CategoryRow(
                  categories: _categories,
                  selectedId: _selectedCategory,
                  loading: _loadingCategories,
                  onSelected: _selectCategory,
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        _searchController.text.trim().isEmpty
                            ? 'Recommended for You'
                            : 'Search Results',
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!_loading && _errorMessage == null)
                      Text(
                        '$_total place${_total == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                if (_source.isNotEmpty && !_loading) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Source: $_source',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                      if (_stale) const _StatusChip(label: 'Cached data'),
                      if (_truncated)
                        const _StatusChip(label: 'Partial results'),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                _buildResults(),
              ]),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildResults() {
    if (_loading && _places.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _places.isEmpty) {
      return _ErrorPanel(message: _errorMessage!, onRetry: () => _loadPlaces());
    }

    if (_places.isEmpty) {
      return const _EmptyPanel();
    }

    return Column(
      children: [
        if (_errorMessage != null) ...[
          _InlineError(
            message: _errorMessage!,
            onRetry: () => _loadPlaces(reset: false),
          ),
          const SizedBox(height: 10),
        ],
        for (var index = 0; index < _places.length; index++) ...[
          _PlaceCard(
            place: _places[index],
            onTap: () => _openPlace(_places[index]),
          ),
          if (index != _places.length - 1) const SizedBox(height: 12),
        ],
        if (_hasNext) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadingMore ? null : () => _loadPlaces(reset: false),
              icon: _loadingMore
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: Text(_loadingMore ? 'Loading...' : 'Load more'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExplorerSearch extends StatelessWidget {
  const _ExplorerSearch({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            maxLength: 120,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Search places...',
              hintStyle: const TextStyle(fontSize: 11),
              prefixIcon: const Icon(Icons.search, size: 17),
              suffixIcon: IconButton(
                onPressed: () => onSubmitted(controller.text),
                icon: const Icon(Icons.arrow_forward, size: 17),
                tooltip: 'Search',
              ),
              filled: true,
              fillColor: const Color(0xFFF0EEEE),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 7),
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () => onSubmitted(controller.text),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFFE8E1DE)),
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              size: 18,
              color: AppColors.brown,
            ),
          ),
        ),
      ),
    ],
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selectedId,
    required this.loading,
    required this.onSelected,
  });

  final List<ExploreCategory> categories;
  final String selectedId;
  final bool loading;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      const ExploreCategory(id: 'all', label: 'All'),
      ...categories.where((category) => category.id != 'all'),
    ];
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final category in items)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                selected: selectedId == category.id,
                label: Text(
                  category.label,
                  style: const TextStyle(fontSize: 9),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onSelected(category.id),
              ),
            ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: .96,
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PlaceImage(url: place.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xD9000000)],
                  stops: [.42, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1C8),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                  Text(
                    '● ${place.subtitle}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFFFE1C8),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.brown, fontSize: 9),
      ),
    ),
  );
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_outlined, size: 46, color: Colors.black45),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFEAEA),
    borderRadius: BorderRadius.circular(8),
    child: ListTile(
      dense: true,
      leading: const Icon(Icons.error_outline, color: AppColors.brown),
      title: Text(message, style: const TextStyle(fontSize: 11)),
      trailing: TextButton(onPressed: onRetry, child: const Text('Retry')),
    ),
  );
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 54),
    child: Column(
      children: [
        Icon(Icons.travel_explore, size: 48, color: Colors.black38),
        SizedBox(height: 12),
        Text('No places match this search.'),
        SizedBox(height: 4),
        Text(
          'Try another keyword or category.',
          style: TextStyle(color: Colors.black54, fontSize: 11),
        ),
      ],
    ),
  );
}
