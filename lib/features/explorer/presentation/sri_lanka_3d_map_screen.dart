import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/navigation/primary_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/rootly_back_button.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'province_detail_screen.dart';
import 'sri_lanka_map_geometry.dart';
import 'sri_lanka_map_painter.dart';
import 'widgets/explorer_footer.dart';

class SriLanka3DMapScreen extends StatefulWidget {
  const SriLanka3DMapScreen({super.key});
  @override
  State<SriLanka3DMapScreen> createState() => _SriLanka3DMapScreenState();
}

class _SriLanka3DMapScreenState extends State<SriLanka3DMapScreen> {
  bool is3D = true;
  double rotation = 0;
  double tilt = 1;
  Offset dragStart = Offset.zero;
  double startRotation = 0;
  double startTilt = 1;
  ProvinceData? selected;

  void beginDrag(DragStartDetails details) {
    dragStart = details.localPosition;
    startRotation = rotation;
    startTilt = tilt;
  }

  void updateDrag(DragUpdateDetails details) {
    if (!is3D) return;
    final delta = details.localPosition - dragStart;
    setState(() {
      rotation = (startRotation + delta.dx / 260).clamp(-.38, .38);
      tilt = (startTilt + delta.dy / 380).clamp(.62, 1.0);
    });
  }

  void selectProvince(TapUpDetails details, Size size) {
    final point = _inverseTransform(details.localPosition, size);
    final rect = provinceMapRect(
      size,
      rotation: rotation,
      tilt: is3D ? tilt : 1,
    );
    final tapped = provinceHitTest(point, rect, selected: selected, is3D: is3D);
    setState(() => selected = tapped == selected ? null : tapped);
  }

  Offset _inverseTransform(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    var x = point.dx - center.dx;
    var y = point.dy - center.dy;
    final cosR = math.cos(-rotation);
    final sinR = math.sin(-rotation);
    final rotatedX = x * cosR - y * sinR;
    final rotatedY = x * sinR + y * cosR;
    x = rotatedX;
    y = is3D ? rotatedY / tilt : rotatedY;
    return Offset(x + center.dx, y + center.dy);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const HomeDrawer(selectedSection: 'Explore Things With 3D Map'),
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
    body: Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF07151C),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Color(0x19000000), blurRadius: 10),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: beginDrag,
                        onPanUpdate: updateDrag,
                        onTapUp: (details) => selectProvince(details, size),
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: size,
                            painter: ProvinceMapPainter(
                              is3D: is3D,
                              rotation: rotation,
                              tilt: tilt,
                              selected: selected,
                            ),
                          ),
                        ),
                      ),
                      if (selected != null)
                        Positioned(
                          right: 12,
                          top: size.height * .28,
                          child: _ProvinceCard(
                            province: selected!,
                            onClose: () => setState(() => selected = null),
                            onExplore: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProvinceDetailScreen(
                                  name: selected!.name,
                                  tagline: selected!.tagline,
                                  sites: selected!.sites,
                                  accentColor: selected!.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xCC07151C),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Text(
                              is3D
                                  ? 'Drag to rotate • Tap a province'
                                  : 'Tap a province to explore',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFB7C6CA),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => setState(() {
                is3D = !is3D;
                rotation = 0;
                tilt = 1;
              }),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                is3D ? Icons.layers_outlined : Icons.view_in_ar_outlined,
                size: 17,
              ),
              label: Text(is3D ? '2D Map' : '3D Map'),
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
}

class _ProvinceCard extends StatelessWidget {
  const _ProvinceCard({
    required this.province,
    required this.onClose,
    required this.onExplore,
  });
  final ProvinceData province;
  final VoidCallback onClose, onExplore;
  @override
  Widget build(BuildContext context) => Container(
    width: 178,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x44000000),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                province.name,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, size: 15),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          province.tagline.toUpperCase(),
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 8),
        for (final site in province.sites)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.brown,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(site, style: const TextStyle(fontSize: 9)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 5),
        FilledButton(
          onPressed: onExplore,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brown,
            minimumSize: const Size.fromHeight(34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text('Explore Region', style: TextStyle(fontSize: 10)),
              ),
              SizedBox(width: 5),
              Icon(Icons.arrow_forward, size: 13),
            ],
          ),
        ),
      ],
    ),
  );
}
