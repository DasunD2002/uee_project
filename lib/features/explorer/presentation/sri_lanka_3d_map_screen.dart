import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import 'widgets/explorer_footer.dart';

class SriLanka3DMapScreen extends StatefulWidget {
  const SriLanka3DMapScreen({super.key});
  @override
  State<SriLanka3DMapScreen> createState() => _SriLanka3DMapScreenState();
}

class _SriLanka3DMapScreenState extends State<SriLanka3DMapScreen> {
  bool is3D = true;
  double rotation = -.08;
  double tilt = .82;
  ProvinceData? selected;

  void selectProvince(TapUpDetails details, Size size) {
    final point = _inverseTransform(details.localPosition, size);
    final rect = provinceMapRect(size);
    for (final province in provinces.reversed) {
      if (provincePath(province, rect).contains(point)) {
        setState(() => selected = province);
        return;
      }
    }
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
    drawer: const HomeDrawer(),
    backgroundColor: const Color(0xFFF8F6F4),
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFEAEA),
      foregroundColor: AppColors.brown,
      centerTitle: true,
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
    body: Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Color(0x19000000), blurRadius: 10),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return Stack(
                    children: [
                      if (is3D)
                        const Positioned.fill(
                          child: ModelViewer(
                            src: 'assets/models/srilanka_provinces.glb',
                            alt:
                                'Interactive 3D map of the provinces of Sri Lanka',
                            cameraControls: true,
                            autoRotate: false,
                            disableZoom: false,
                            backgroundColor: Colors.transparent,
                            interactionPrompt: InteractionPrompt.none,
                            cameraOrbit: '0deg 28deg 105%',
                          ),
                        )
                      else
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) => selectProvince(details, size),
                          child: CustomPaint(
                            size: size,
                            painter: ProvinceMapPainter(
                              is3D: false,
                              rotation: rotation,
                              tilt: tilt,
                              selected: selected,
                            ),
                          ),
                        ),
                      if (is3D)
                        Positioned(
                          left: 10,
                          top: 10,
                          child: PopupMenuButton<ProvinceData>(
                            tooltip: 'Choose a province',
                            onSelected: (province) =>
                                setState(() => selected = province),
                            itemBuilder: (_) => [
                              for (final province in provinces)
                                PopupMenuItem(
                                  value: province,
                                  child: Text(province.shortName),
                                ),
                            ],
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: AppColors.brown,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Select province',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
                            onExplore: () =>
                                Navigator.pushNamed(context, '/explorer'),
                          ),
                        ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .9),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Text(
                              is3D
                                  ? 'Drag to rotate • Pinch to zoom'
                                  : 'Tap a province',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.black54,
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
                if (!is3D) {
                  rotation = 0;
                  tilt = 1;
                } else {
                  rotation = -.08;
                  tilt = .82;
                }
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
      selectedIndex: 3,
      onSelected: (index) {
        if (index == 0)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        if (index == 1) Navigator.pushReplacementNamed(context, '/explorer');
      },
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
              Text('Explore Region', style: TextStyle(fontSize: 10)),
              SizedBox(width: 5),
              Icon(Icons.arrow_forward, size: 13),
            ],
          ),
        ),
      ],
    ),
  );
}

class ProvinceMapPainter extends CustomPainter {
  const ProvinceMapPainter({
    required this.is3D,
    required this.rotation,
    required this.tilt,
    required this.selected,
  });
  final bool is3D;
  final double rotation, tilt;
  final ProvinceData? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(1.0, is3D ? tilt : 1.0);
    canvas.translate(-center.dx, -center.dy);
    final rect = provinceMapRect(size);

    if (is3D) {
      for (var depth = 15; depth >= 1; depth--) {
        for (final province in provinces) {
          final shifted = provincePath(
            province,
            rect,
          ).shift(Offset(depth * .38, depth * .72));
          canvas.drawPath(
            shifted,
            Paint()..color = Color.lerp(province.color, Colors.black, .48)!,
          );
        }
      }
    }

    for (final province in provinces) {
      final path = provincePath(province, rect);
      final isSelected = selected?.name == province.name;
      canvas.drawPath(
        path,
        Paint()
          ..color = isSelected
              ? Color.lerp(province.color, Colors.white, .18)!
              : province.color,
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3 : 1.2
          ..color = isSelected ? Colors.white : Colors.white70,
      );
      final labelPoint = Offset(
        rect.left + province.label.dx * rect.width,
        rect.top + province.label.dy * rect.height,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: province.shortName,
          style: TextStyle(
            fontSize: isSelected ? 9 : 7,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        labelPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ProvinceMapPainter old) =>
      old.is3D != is3D ||
      old.rotation != rotation ||
      old.tilt != tilt ||
      old.selected != selected;
}

Rect provinceMapRect(Size size) {
  final height = math.min(size.height * .86, 510.0);
  final width = math.min(size.width * .68, height * .56);
  return Rect.fromCenter(
    center: Offset(size.width * .43, size.height * .49),
    width: width,
    height: height,
  );
}

Path provincePath(ProvinceData province, Rect rect) {
  final path = Path();
  for (var i = 0; i < province.points.length; i++) {
    final p = province.points[i];
    final point = Offset(
      rect.left + p.dx * rect.width,
      rect.top + p.dy * rect.height,
    );
    if (i == 0)
      path.moveTo(point.dx, point.dy);
    else
      path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

class ProvinceData {
  const ProvinceData({
    required this.name,
    required this.shortName,
    required this.tagline,
    required this.sites,
    required this.color,
    required this.points,
    required this.label,
  });
  final String name, shortName, tagline;
  final List<String> sites;
  final Color color;
  final List<Offset> points;
  final Offset label;
}

const provinces = <ProvinceData>[
  ProvinceData(
    name: 'Northern Province',
    shortName: 'Northern',
    tagline: 'Heritage of the north',
    sites: ['Jaffna Fort', 'Nallur Kandaswamy Temple'],
    color: Color(0xFFF03A3E),
    label: Offset(.49, .14),
    points: [
      Offset(.36, .015),
      Offset(.43, 0),
      Offset(.50, .018),
      Offset(.57, .010),
      Offset(.62, .038),
      Offset(.68, .064),
      Offset(.72, .105),
      Offset(.75, .155),
      Offset(.70, .205),
      Offset(.62, .232),
      Offset(.53, .255),
      Offset(.43, .238),
      Offset(.36, .257),
      Offset(.29, .225),
      Offset(.27, .175),
      Offset(.22, .145),
      Offset(.25, .105),
      Offset(.31, .085),
    ],
  ),
  ProvinceData(
    name: 'North Western Province',
    shortName: 'North Western',
    tagline: 'Coasts and kingdoms',
    sites: ['Yapahuwa Rock Fortress', 'Munneswaram Temple'],
    color: Color(0xFF50DD54),
    label: Offset(.29, .43),
    points: [
      Offset(.29, .225),
      Offset(.36, .257),
      Offset(.43, .238),
      Offset(.53, .255),
      Offset(.57, .330),
      Offset(.53, .405),
      Offset(.48, .485),
      Offset(.39, .520),
      Offset(.31, .555),
      Offset(.22, .535),
      Offset(.17, .485),
      Offset(.145, .425),
      Offset(.16, .355),
      Offset(.18, .300),
      Offset(.23, .265),
    ],
  ),
  ProvinceData(
    name: 'North Central Province',
    shortName: 'North Central',
    tagline: 'Ancient capitals',
    sites: ['Anuradhapura', 'Polonnaruwa'],
    color: Color(0xFFF0BB37),
    label: Offset(.56, .35),
    points: [
      Offset(.53, .255),
      Offset(.62, .232),
      Offset(.70, .205),
      Offset(.75, .225),
      Offset(.78, .285),
      Offset(.76, .345),
      Offset(.80, .405),
      Offset(.74, .455),
      Offset(.68, .475),
      Offset(.62, .455),
      Offset(.56, .475),
      Offset(.48, .485),
      Offset(.53, .405),
      Offset(.57, .330),
    ],
  ),
  ProvinceData(
    name: 'Eastern Province',
    shortName: 'Eastern',
    tagline: 'Eastern shores',
    sites: ['Koneswaram Temple', 'Batticaloa Fort'],
    color: Color(0xFFF47C32),
    label: Offset(.79, .50),
    points: [
      Offset(.70, .205),
      Offset(.75, .185),
      Offset(.80, .205),
      Offset(.82, .255),
      Offset(.86, .295),
      Offset(.88, .355),
      Offset(.92, .410),
      Offset(.925, .475),
      Offset(.91, .535),
      Offset(.93, .600),
      Offset(.91, .670),
      Offset(.87, .735),
      Offset(.82, .780),
      Offset(.76, .760),
      Offset(.72, .700),
      Offset(.70, .630),
      Offset(.67, .565),
      Offset(.68, .475),
      Offset(.74, .455),
      Offset(.80, .405),
      Offset(.76, .345),
      Offset(.78, .285),
      Offset(.75, .225),
    ],
  ),
  ProvinceData(
    name: 'Central Province',
    shortName: 'Central',
    tagline: 'Highland heritage',
    sites: ['Temple of the Tooth', 'Dambulla Cave Temple'],
    color: Color(0xFF5FC07C),
    label: Offset(.52, .57),
    points: [
      Offset(.48, .485),
      Offset(.56, .475),
      Offset(.62, .455),
      Offset(.68, .475),
      Offset(.67, .565),
      Offset(.70, .630),
      Offset(.65, .680),
      Offset(.58, .705),
      Offset(.50, .690),
      Offset(.44, .650),
      Offset(.39, .585),
      Offset(.39, .520),
    ],
  ),
  ProvinceData(
    name: 'Western Province',
    shortName: 'Western',
    tagline: 'Gateway to the island',
    sites: ['Colombo National Museum', 'Kelaniya Temple'],
    color: Color(0xFF43D2C3),
    label: Offset(.22, .67),
    points: [
      Offset(.145, .425),
      Offset(.17, .485),
      Offset(.22, .535),
      Offset(.31, .555),
      Offset(.39, .520),
      Offset(.39, .585),
      Offset(.37, .650),
      Offset(.34, .710),
      Offset(.37, .775),
      Offset(.32, .825),
      Offset(.24, .815),
      Offset(.20, .770),
      Offset(.17, .700),
      Offset(.15, .625),
      Offset(.13, .545),
    ],
  ),
  ProvinceData(
    name: 'Sabaragamuwa Province',
    shortName: 'Sabaragamuwa',
    tagline: 'Gems and wilderness',
    sites: ['Adam’s Peak', 'Ratnapura Museum'],
    color: Color(0xFF438ED8),
    label: Offset(.42, .74),
    points: [
      Offset(.39, .585),
      Offset(.44, .650),
      Offset(.50, .690),
      Offset(.58, .705),
      Offset(.57, .770),
      Offset(.53, .825),
      Offset(.46, .850),
      Offset(.37, .835),
      Offset(.32, .825),
      Offset(.37, .775),
      Offset(.34, .710),
      Offset(.37, .650),
    ],
  ),
  ProvinceData(
    name: 'Uva Province',
    shortName: 'Uva',
    tagline: 'Highland heritage',
    sites: ['Buduruwagala Rock', 'Muthiyangana Temple'],
    color: Color(0xFF4167D9),
    label: Offset(.66, .72),
    points: [
      Offset(.58, .705),
      Offset(.65, .680),
      Offset(.70, .630),
      Offset(.72, .700),
      Offset(.76, .760),
      Offset(.82, .780),
      Offset(.79, .835),
      Offset(.72, .865),
      Offset(.64, .850),
      Offset(.57, .770),
    ],
  ),
  ProvinceData(
    name: 'Southern Province',
    shortName: 'Southern',
    tagline: 'Coastal culture',
    sites: ['Galle Fort', 'Matara Star Fort'],
    color: Color(0xFF6550D7),
    label: Offset(.51, .91),
    points: [
      Offset(.24, .815),
      Offset(.32, .825),
      Offset(.37, .835),
      Offset(.46, .850),
      Offset(.53, .825),
      Offset(.57, .770),
      Offset(.64, .850),
      Offset(.72, .865),
      Offset(.79, .835),
      Offset(.77, .885),
      Offset(.72, .925),
      Offset(.65, .955),
      Offset(.57, .982),
      Offset(.48, 1),
      Offset(.39, .988),
      Offset(.31, .960),
      Offset(.25, .920),
      Offset(.21, .870),
    ],
  ),
];

// Kept temporarily as a geometry fallback for visual comparison while the
// imported GLB is being evaluated on target devices.
// ignore: unused_element
const _legacyProvinces = <ProvinceData>[
  ProvinceData(
    name: 'Northern Province',
    shortName: 'Northern',
    tagline: 'Heritage of the north',
    sites: ['Jaffna Fort', 'Nallur Kandaswamy Temple'],
    color: Color(0xFFE44842),
    label: Offset(.48, .11),
    points: [
      Offset(.41, 0),
      Offset(.61, .02),
      Offset(.66, .17),
      Offset(.57, .25),
      Offset(.38, .22),
      Offset(.34, .09),
    ],
  ),
  ProvinceData(
    name: 'North Western Province',
    shortName: 'North Western',
    tagline: 'Coasts and kingdoms',
    sites: ['Yapahuwa Rock Fortress', 'Munneswaram Temple'],
    color: Color(0xFF5DBE73),
    label: Offset(.30, .37),
    points: [
      Offset(.38, .22),
      Offset(.57, .25),
      Offset(.51, .43),
      Offset(.31, .49),
      Offset(.18, .39),
      Offset(.23, .25),
    ],
  ),
  ProvinceData(
    name: 'North Central Province',
    shortName: 'North Central',
    tagline: 'Ancient capitals',
    sites: ['Anuradhapura', 'Polonnaruwa'],
    color: Color(0xFFE5A33A),
    label: Offset(.58, .34),
    points: [
      Offset(.57, .25),
      Offset(.75, .22),
      Offset(.83, .42),
      Offset(.65, .49),
      Offset(.51, .43),
    ],
  ),
  ProvinceData(
    name: 'Eastern Province',
    shortName: 'Eastern',
    tagline: 'Eastern shores',
    sites: ['Koneswaram Temple', 'Batticaloa Fort'],
    color: Color(0xFF35AFC1),
    label: Offset(.79, .57),
    points: [
      Offset(.75, .22),
      Offset(.88, .31),
      Offset(.91, .63),
      Offset(.78, .79),
      Offset(.67, .68),
      Offset(.65, .49),
      Offset(.83, .42),
    ],
  ),
  ProvinceData(
    name: 'Central Province',
    shortName: 'Central',
    tagline: 'Highland heritage',
    sites: ['Temple of the Tooth', 'Dambulla Cave Temple'],
    color: Color(0xFFE0764D),
    label: Offset(.52, .55),
    points: [
      Offset(.51, .43),
      Offset(.65, .49),
      Offset(.67, .68),
      Offset(.51, .72),
      Offset(.39, .60),
      Offset(.31, .49),
    ],
  ),
  ProvinceData(
    name: 'Western Province',
    shortName: 'Western',
    tagline: 'Gateway to the island',
    sites: ['Colombo National Museum', 'Kelaniya Temple'],
    color: Color(0xFF46A6DF),
    label: Offset(.22, .59),
    points: [
      Offset(.18, .39),
      Offset(.31, .49),
      Offset(.39, .60),
      Offset(.31, .72),
      Offset(.18, .69),
      Offset(.12, .53),
    ],
  ),
  ProvinceData(
    name: 'Sabaragamuwa Province',
    shortName: 'Sabaragamuwa',
    tagline: 'Gems and wilderness',
    sites: ['Adam’s Peak', 'Ratnapura Museum'],
    color: Color(0xFF4EBBA7),
    label: Offset(.38, .72),
    points: [
      Offset(.39, .60),
      Offset(.51, .72),
      Offset(.47, .84),
      Offset(.28, .82),
      Offset(.31, .72),
    ],
  ),
  ProvinceData(
    name: 'Uva Province',
    shortName: 'Uva',
    tagline: 'Highland heritage',
    sites: ['Buduruwagala Rock', 'Muthiyangana Temple'],
    color: Color(0xFF735BC5),
    label: Offset(.62, .78),
    points: [
      Offset(.51, .72),
      Offset(.67, .68),
      Offset(.78, .79),
      Offset(.68, .91),
      Offset(.47, .84),
    ],
  ),
  ProvinceData(
    name: 'Southern Province',
    shortName: 'Southern',
    tagline: 'Coastal culture',
    sites: ['Galle Fort', 'Matara Star Fort'],
    color: Color(0xFF5743AE),
    label: Offset(.47, .92),
    points: [
      Offset(.28, .82),
      Offset(.47, .84),
      Offset(.68, .91),
      Offset(.59, 1),
      Offset(.36, .98),
      Offset(.21, .90),
    ],
  ),
];
