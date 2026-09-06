import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'field_notes_archive_screen.dart';
import 'field_note_editor_screen.dart';
import 'widgets/explorer_footer.dart';

class ProvinceDetailScreen extends StatelessWidget {
  const ProvinceDetailScreen({
    super.key,
    required this.name,
    required this.tagline,
    required this.sites,
    required this.accentColor,
  });

  final String name;
  final String tagline;
  final List<String> sites;
  final Color accentColor;

  String get _description => switch (name) {
    'Uva Province' =>
      'Nestled in the southeastern part of the island, Uva Province is renowned for its dramatic highlands, ancient rock temples, and deeply rooted artistic traditions.',
    'Northern Province' =>
      'A storied northern landscape shaped by ancient kingdoms, coastal communities, sacred temples, and a distinctive Tamil cultural heritage.',
    'North Central Province' =>
      'The heartland of Sri Lanka’s ancient capitals, filled with monumental stupas, reservoirs, monasteries, and living archaeological landscapes.',
    'Central Province' =>
      'A cool highland region where royal heritage, sacred traditions, mountain scenery, and generations of craft meet.',
    'Eastern Province' =>
      'A diverse eastern coast of historic forts, sacred shrines, lagoons, beaches, and long-standing multicultural traditions.',
    'Western Province' =>
      'Sri Lanka’s lively western gateway, bringing together colonial landmarks, museums, temples, and contemporary urban culture.',
    'Southern Province' =>
      'A maritime province celebrated for fortified towns, temple traditions, artisan communities, and its historic Indian Ocean coast.',
    'Sabaragamuwa Province' =>
      'A lush province of pilgrimage routes, gem-mining heritage, forest traditions, and dramatic mountain landscapes.',
    _ =>
      'A culturally rich region shaped by historic kingdoms, sacred places, local craftsmanship, and living community traditions.',
  };

  String get _heroImage => switch (name) {
    'Southern Province' ||
    'Western Province' => 'assets/images/login_image.jpg',
    'North Western Province' => 'assets/images/mask_carver.png',
    _ => 'assets/images/gal_vihara.png',
  };

  void _navigate(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(context, '/explorer', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const HomeDrawer(),
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
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, size: 21),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 26),
      children: [
        _PageHeading(accentColor: accentColor),
        const SizedBox(height: 28),
        _Hero(name: name, tagline: tagline, image: _heroImage),
        const SizedBox(height: 24),
        _InfoCard(
          title: 'Region at a Glance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_description, style: _bodyStyle),
              const SizedBox(height: 14),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _Tag(
                    label: name == 'Uva Province'
                        ? 'Ancient Kingdoms'
                        : 'Living Heritage',
                  ),
                  _Tag(label: tagline),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _InfoCard(
          title: 'Visitor Essentials',
          child: Column(
            children: [
              _Essential(
                icon: Icons.thermostat_outlined,
                title: 'Climate',
                value: 'Tropical climate with regional highland variation.',
              ),
              _Essential(
                icon: Icons.directions_car_outlined,
                title: 'Access',
                value: 'Main roads and local transport links available.',
              ),
              _Essential(
                icon: Icons.map_outlined,
                title: 'Local Guides',
                value: 'Find a certified regional guide',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text('Top Heritage Sites', style: _sectionTitle),
        const SizedBox(height: 12),
        for (var i = 0; i < sites.length; i++) ...[
          _HeritageCard(
            province: name,
            title: sites[i],
            image: i.isEven
                ? 'assets/images/gal_vihara.png'
                : 'assets/images/login_image.jpg',
            category: i.isEven ? 'HERITAGE SITE' : 'SACRED SITE',
            description:
                'Discover the history, craftsmanship, and community stories preserved at ${sites[i]} in $name.',
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cultural Traditions', style: _sectionTitle),
            TextButton(onPressed: () {}, child: const Text('View all →')),
          ],
        ),
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _TraditionCard(
                image: 'assets/images/mask_carver.png',
                title: 'Regional Craftsmanship',
                description: 'Age-old skills passed through generations.',
              ),
              _TraditionCard(
                image: 'assets/images/login_image.jpg',
                title: 'Rituals & Festivals',
                description:
                    'Living traditions celebrated by local communities.',
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: ExplorerFooter(
      selectedIndex: 1,
      onSelected: (index) => _navigate(context, index),
    ),
  );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.accentColor});
  final Color accentColor;
  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFFFEBDD),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: -2,
          top: -8,
          child: CircleAvatar(radius: 17, backgroundColor: accentColor),
        ),
        const Text(
          'Explore Province',
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
          Image.asset(image, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xD9000000)],
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
  });
  final String province, title, image, category, description;
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            image,
            height: 155,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
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
  });
  final String image, title, description;
  @override
  Widget build(BuildContext context) => Container(
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
          child: Image.asset(
            image,
            height: 125,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
