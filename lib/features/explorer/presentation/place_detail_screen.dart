import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/explorer_footer.dart';
import 'journey_planner_screen.dart';
import '../domain/place.dart';
import '../data/places_repository.dart';
import 'widgets/province_source_button.dart';
import 'widgets/place_image.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({super.key, required this.place, this.repository});

  final Place place;
  final PlacesRepository? repository;
  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final PlacesRepository _repository;
  late final bool _ownsRepository;
  late Place _place;
  bool _loadingDetail = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _place = widget.place;
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? PlacesRepository();
    unawaited(_loadDetail());
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });
    try {
      final place = await _repository.fetchPlace(_place.id);
      if (!mounted) return;
      setState(() {
        _place = place;
        _loadingDetail = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _detailError =
            'Could not load the full story. Showing available details.';
        _loadingDetail = false;
      });
    }
  }

  @override
  void dispose() {
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  Widget _placeImage() => PlaceImage(url: _place.imageUrl);

  @override
  Widget build(BuildContext context) => Scaffold(
    key: scaffoldKey,
    drawer: const HomeDrawer(selectedSection: 'Explore Places'),
    backgroundColor: const Color(0xFFF8F6F4),
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
    body: ListView(
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            SizedBox(height: 280, width: double.infinity, child: _placeImage()),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 15,
              right: 15,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _place.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _place.description ?? 'Discover the story of this place.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '● ${_place.subtitle}  ·  ${_place.category}',
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _ContentCard(
                title: 'Historical Narrative',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadingDetail) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 14),
                    ],
                    if (_detailError case final error?) ...[
                      Text(
                        error,
                        style: const TextStyle(color: AppColors.brown),
                      ),
                      TextButton(
                        onPressed: _loadDetail,
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      _place.description ??
                          'No detailed description is available from the source for this place.',
                      style: _bodyStyle,
                    ),
                    const SizedBox(height: 12),
                    ProvinceSourceButton(
                      sourceUrl: _place.sourceUrl,
                      imageSourceUrl: _place.imageSourceUrl,
                      wikipediaUrl: _place.wikipediaUrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/journey'),
                      builder: (_) =>
                          JourneyPlannerScreen(selectedPlace: _place),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Add to Journey'),
                ),
              ),
              const SizedBox(height: 12),
              _ContentCard(
                title: 'Place information',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.category_outlined,
                      title: 'Category',
                      value: _place.category,
                    ),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      title: 'Location',
                      value: _place.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 1,
      onSelected: (index) => navigateToPrimaryDestination(context, index),
    ),
  );
}

const _bodyStyle = TextStyle(
  fontSize: 15,
  height: 1.6,
  color: Color(0xFF534B47),
);

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE8E0DC)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.brown,
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        child,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.brown),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
