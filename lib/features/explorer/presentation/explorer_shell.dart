import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../data/places_repository.dart';
import '../domain/place.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'redesigned_explorer_screen.dart';
import 'widgets/explorer_footer.dart';

const _brown = Color(0xFF713021);

class ExplorerShell extends StatefulWidget {
  const ExplorerShell({super.key});
  @override
  State<ExplorerShell> createState() => _ExplorerShellState();
}

class _ExplorerShellState extends State<ExplorerShell> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final repository = PlacesRepository();
  int index = 0;

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) => Scaffold(
    key: scaffoldKey,
    drawer: const HomeDrawer(),
    body: IndexedStack(
      index: index,
      children: [
        RedesignedExplorerScreen(
          onOpenDrawer: openDrawer,
        ),
        MapScreen(repository: repository, onOpenDrawer: openDrawer),
        _ComingSoon(label: 'Journeys', onOpenDrawer: openDrawer),
        _ComingSoon(label: 'Profile', onOpenDrawer: openDrawer),
      ],
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: index < 2 ? 1 : index,
      onSelected: (value) {
        if (value == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        } else if (value == 3) {
          Navigator.pushNamed(context, '/province-map');
        } else {
          setState(() => index = value == 1 ? 0 : value);
        }
      },
    ),
  );
}

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({
    super.key,
    required this.repository,
    required this.onShowMap,
    required this.onOpenDrawer,
  });
  final PlacesRepository repository;
  final VoidCallback onShowMap;
  final VoidCallback onOpenDrawer;
  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final search = TextEditingController();
  late Future<List<Place>> places;
  late Future<List<String>> history;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    places = widget.repository.suggestions();
    history = widget.repository.history();
  }

  Future<void> _submit(String value) async {
    if (value.trim().isEmpty) return;
    setState(() {
      places = widget.repository.search(value.trim());
      history = widget.repository.history();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: const Color(0xFFFFFBF8),
          foregroundColor: _brown,
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
              onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
              icon: const Icon(Icons.search, size: 20),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: search,
                  onSubmitted: _submit,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search eras, regions, or sites...',
                    prefixIcon: const Icon(Icons.search, size: 19),
                    suffixIcon: IconButton(
                      onPressed: () => _submit(search.text),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        ['All Eras', 'Ancient Ruins', 'Sacred Sites', 'Museums']
                            .map(
                              (label) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ActionChip(
                                  label: Text(
                                    label,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onPressed: () {
                                    search.text = label;
                                    _submit(label);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 22),
                const _Heading('Recommended for You'),
                const SizedBox(height: 10),
                FutureBuilder<List<Place>>(
                  future: places,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    return Column(
                      children: snapshot.data!
                          .take(4)
                          .map(
                            (place) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HeroPlaceCard(
                                place: place,
                                imageUrl: widget.repository.photoUrl(place),
                                onTap: widget.onShowMap,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const _Heading('Nearby Discoveries'),
                const SizedBox(height: 8),
                FutureBuilder<List<String>>(
                  future: history,
                  builder: (context, snapshot) => Column(
                    children: (snapshot.data ?? const <String>[])
                        .map(
                          (query) => Card(
                            margin: const EdgeInsets.only(bottom: 7),
                            child: ListTile(
                              leading: const Icon(Icons.history, color: _brown),
                              title: Text(
                                query,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: const Text('Previous search'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                search.text = query;
                                _submit(query);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Map powered by MapLibre and OpenStreetMap demo tiles.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
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

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.repository,
    required this.onOpenDrawer,
  });
  final PlacesRepository repository;
  final VoidCallback onOpenDrawer;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Place>> places;
  int selected = 0;
  MapLibreMapController? mapController;
  @override
  void initState() {
    super.initState();
    places = widget.repository.search(
      'cultural heritage sites near Polonnaruwa',
      remember: false,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Place>>(
    future: places,
    builder: (context, snapshot) {
      final items =
          snapshot.data ??
          PlacesRepository.fallbackPlaces
              .where((place) => place.subtitle.contains('Polonnaruwa'))
              .toList();
      return Stack(
        children: [
          MapLibreMap(
            styleString: 'https://demotiles.maplibre.org/style.json',
            initialCameraPosition: const CameraPosition(
              target: LatLng(7.9568, 81.0027),
              zoom: 12.5,
            ),
            onMapCreated: (controller) => mapController = controller,
            onStyleLoadedCallback: () async {
              final controller = mapController;
              if (controller == null) return;
              await controller.addSymbols(
                items
                    .map(
                      (place) => SymbolOptions(
                        geometry: place.location,
                        iconImage: 'marker-15',
                        iconSize: 1.5,
                        textField: place.name,
                        textOffset: const Offset(0, 1.8),
                        textSize: 11,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Material(
                    elevation: 4,
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: widget.onOpenDrawer,
                      icon: const Icon(Icons.menu, color: _brown),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(22),
                      child: const TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Polonnaruwa',
                          prefixIcon: Icon(Icons.map_outlined, color: _brown),
                          suffixIcon: Icon(Icons.tune),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (items.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              height: 205,
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: .83,
                  initialPage: selected,
                ),
                itemCount: items.length,
                onPageChanged: (value) => setState(() => selected = value),
                itemBuilder: (_, i) => _MapPlaceCard(
                  place: items[i],
                  imageUrl: widget.repository.photoUrl(items[i]),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _HeroPlaceCard extends StatelessWidget {
  const _HeroPlaceCard({
    required this.place,
    required this.imageUrl,
    required this.onTap,
  });
  final Place place;
  final String? imageUrl;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: .9,
    child: Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _PlaceImage(url: imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xD9000000)],
                  stops: [.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(
                      place.category,
                      style: const TextStyle(fontSize: 9),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    place.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '◉ ${place.subtitle}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
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

class _MapPlaceCard extends StatelessWidget {
  const _MapPlaceCard({required this.place, required this.imageUrl});
  final Place place;
  final String? imageUrl;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 108,
          width: double.infinity,
          child: _PlaceImage(url: imageUrl),
        ),
        Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.category.toUpperCase(),
                style: const TextStyle(fontSize: 8, color: Colors.black54),
              ),
              Text(
                place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                place.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                '★ ${place.rating?.toStringAsFixed(1) ?? 'New'}',
                style: const TextStyle(fontSize: 10, color: _brown),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlaceImage extends StatelessWidget {
  const _PlaceImage({required this.url});
  final String? url;
  @override
  Widget build(BuildContext context) => url == null
      ? const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7B99E), Color(0xFF657B6D)],
            ),
          ),
          child: Center(
            child: Icon(Icons.account_balance, color: Colors.white70, size: 46),
          ),
        )
      : Image.network(
          url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFFD7B99E),
            child: Icon(Icons.account_balance, color: Colors.white),
          ),
        );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'serif',
      color: _brown,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label, required this.onOpenDrawer});
  final String label;
  final VoidCallback onOpenDrawer;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                onPressed: onOpenDrawer,
                icon: const Icon(Icons.menu, color: _brown),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _brown,
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(child: Center(child: Text('$label coming soon'))),
      ],
    ),
  );
}

class _ExplorerNav extends StatelessWidget {
  const _ExplorerNav({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;
  static const items = [
    (Icons.explore_outlined, 'Explore'),
    (Icons.map_outlined, 'Map'),
    (Icons.route_outlined, 'Journeys'),
    (Icons.person_outline, 'Profile'),
  ];
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      height: 62,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 10)],
      ),
      child: Row(
        children: List.generate(
          items.length,
          (i) => Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Container(
                decoration: BoxDecoration(
                  color: i == index ? const Color(0xFFFFDEC6) : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].$1, size: 19, color: _brown),
                    Text(items[i].$2, style: const TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
