import 'package:flutter/material.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/explorer_footer.dart';
import 'journey_planner_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({
    super.key,
    this.title = 'Gal Vihara',
    this.imagePath = 'assets/images/gal_vihara.png',
    this.imageUrl,
    this.subtitle = 'Polonnaruwa, Sri Lanka',
    this.category = 'Classical Era',
    this.description,
  });

  final String title;
  final String imagePath;
  final String? imageUrl;
  final String subtitle;
  final String category;
  final String? description;
  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _placeImage() {
    final imageUrl = widget.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(widget.imagePath, fit: BoxFit.cover);
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Image.asset(widget.imagePath, fit: BoxFit.cover),
    );
  }

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
            SizedBox(height: 230, width: double.infinity, child: _placeImage()),
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
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.description ?? 'Discover the story of this place.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '● ${widget.subtitle}  ·  ${widget.category}',
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
                title: 'About this place',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.description ??
                          'Explore ${widget.title} and its cultural significance.',
                      style: _bodyStyle,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: _placeImage(),
                      ),
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
                      builder: (_) => JourneyPlannerScreen(
                        selectedTitle: widget.title,
                        selectedImagePath: widget.imagePath,
                      ),
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
                      value: widget.category,
                    ),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      title: 'Location',
                      value: widget.subtitle,
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
  fontSize: 11,
  height: 1.55,
  color: Color(0xFF534B47),
);

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
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
            fontSize: 17,
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
