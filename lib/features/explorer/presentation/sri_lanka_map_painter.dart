import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'sri_lanka_map_geometry.dart';

// Every province shares the same resting height. Only selection adds relief.
const _baseDepth = 8.0;
const _selectedLift = 34.0;

// Resolve coastal inlets once in reference coordinates, before scaling.
final _provinceOutlines = {
  for (final province in provinces) province: _outlinePath(province),
};

Path _outlinePath(ProvinceData province) {
  final path = Path()..addPolygon(province.points, true);
  for (final island in province.islands) {
    path.addPolygon(island, true);
  }
  return path;
}

final _provinceSurfaces = {
  for (final province in provinces)
    province: _cutCoastalInlets(province, _provinceOutlines[province]!),
};

Path _cutCoastalInlets(ProvinceData province, Path outline) {
  var surface = outline;
  for (final cutout in province.cutouts) {
    surface = Path.combine(
      PathOperation.difference,
      surface,
      Path()..addPolygon(cutout, true),
    );
  }
  return surface;
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
    if (size.isEmpty) return;
    _paintBackground(canvas, size);
    final rect = provinceMapRect(
      size,
      rotation: rotation,
      tilt: is3D ? tilt : 1,
    );
    final scale = rect.width / sriLankaMapViewBox.width;
    final center = size.center(Offset.zero);
    final paths = {
      for (final province in provinces) province: provincePath(province, rect),
    };

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(1.0, is3D ? tilt : 1.0);
    canvas.translate(-center.dx, -center.dy);

    if (is3D) {
      final silhouette = Path();
      for (final path in paths.values) {
        silhouette.addPath(path, Offset.zero);
      }
      canvas.drawPath(
        silhouette.shift(Offset(10 * scale, 18 * scale)),
        Paint()
          ..color = const Color(0xB8000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * scale),
      );

      // The resting map is one level, with no permanently raised province.
      for (final province in provinces) {
        _paintSides(
          canvas,
          province,
          paths[province]!,
          rect,
          scale,
          depth: _baseDepth,
        );
      }
    }

    for (final province in provinces) {
      _paintSurface(
        canvas,
        province,
        paths[province]!,
        scale,
        highlight: !is3D && selected == province,
      );
    }

    for (final province in provinces) {
      if (is3D && selected == province) continue;
      _paintLabel(canvas, province, rect, scale);
    }

    final active = selected;
    if (is3D && active != null) {
      final offset = provinceSurfaceOffset(active, rect, selected: active);
      final raisedPath = paths[active]!.shift(offset);
      canvas.drawPath(
        paths[active]!.shift(Offset(7 * scale, 10 * scale)),
        Paint()
          ..color = const Color(0x80000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * scale),
      );
      // Draw the selected piece last so it rises above every neighbor.
      _paintSides(
        canvas,
        active,
        raisedPath,
        rect,
        scale,
        depth: _baseDepth + _selectedLift,
        surfaceOffset: offset,
      );
      _paintSurface(canvas, active, raisedPath, scale, highlight: true);
      _paintLabel(canvas, active, rect, scale, surfaceOffset: offset);
    }
    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.65, -.45),
          radius: 1.3,
          colors: [Color(0xFF1B2B32), Color(0xFF06141B), Color(0xFF030D13)],
          stops: [0, .65, 1],
        ).createShader(bounds),
    );

    // A fine woven surface echoes the dark material in the reference.
    final texture = Path();
    const spacing = 9.0;
    for (var x = -size.height; x < size.width; x += spacing) {
      texture.moveTo(x, 0);
      texture.lineTo(x + size.height, size.height);
      texture.moveTo(x + size.height, 0);
      texture.lineTo(x, size.height);
    }
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawPath(
      texture,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .45
        ..shader = const LinearGradient(
          colors: [Color(0x0E93A7AE), Color(0x0093A7AE)],
        ).createShader(bounds),
    );
    canvas.restore();
  }

  void _paintSides(
    Canvas canvas,
    ProvinceData province,
    Path surface,
    Rect rect,
    double scale, {
    required double depth,
    Offset surfaceOffset = Offset.zero,
  }) {
    final extrusion = Offset(depth * .14 * scale, depth * scale);
    canvas.drawPath(
      surface.shift(extrusion),
      Paint()..color = Color.lerp(province.color, Colors.black, .40)!,
    );

    for (final ring in [
      province.points,
      ...province.islands,
      ...province.cutouts,
    ]) {
      // Inlets may cross the coast. Their walls belong inside the island body.
      canvas.save();
      if (province.cutouts.contains(ring)) {
        final outline = _transformReferencePath(
          _provinceOutlines[province]!,
          rect,
        ).shift(surfaceOffset);
        canvas.clipPath(
          Path.combine(PathOperation.union, outline, outline.shift(extrusion)),
        );
      }
      var area = 0.0;
      for (var i = 0; i < ring.length; i++) {
        final a = ring[i];
        final b = ring[(i + 1) % ring.length];
        area += a.dx * b.dy - b.dx * a.dy;
      }
      final direction = area < 0 ? -1.0 : 1.0;
      for (var i = 0; i < ring.length; i++) {
        final a = provinceMapPoint(ring[i], rect) + surfaceOffset;
        final b =
            provinceMapPoint(ring[(i + 1) % ring.length], rect) + surfaceOffset;
        final edge = b - a;
        if (edge.distance == 0) continue;
        final light = direction * (edge.dx - edge.dy) / edge.distance;
        final darkness = (.32 - light * .10).clamp(.16, .48);
        final face = Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(b.dx + extrusion.dx, b.dy + extrusion.dy)
          ..lineTo(a.dx + extrusion.dx, a.dy + extrusion.dy)
          ..close();
        canvas.drawPath(
          face,
          Paint()..color = Color.lerp(province.color, Colors.black, darkness)!,
        );
      }
      canvas.restore();
    }
  }

  void _paintSurface(
    Canvas canvas,
    ProvinceData province,
    Path path,
    double scale, {
    required bool highlight,
  }) {
    final color = highlight
        ? Color.lerp(province.color, Colors.white, .15)!
        : province.color;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, is3D ? .10 : 0)!,
            color,
            Color.lerp(color, Colors.black, is3D ? .12 : 0)!,
          ],
          stops: const [0, .5, 1],
        ).createShader(path.getBounds()),
    );
    // Keep the borders subtle: the reference has joined colored faces.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = highlight ? 2 : math.max(.35, .9 * scale)
        ..color = highlight
            ? const Color(0xFFFFF3CE)
            : Color.lerp(color, Colors.white, .22)!.withValues(alpha: .55),
    );
  }

  void _paintLabel(
    Canvas canvas,
    ProvinceData province,
    Rect rect,
    double scale, {
    Offset surfaceOffset = Offset.zero,
  }) {
    final labelPoint = provinceMapPoint(province.label, rect) + surfaceOffset;
    final textPainter = TextPainter(
      text: TextSpan(
        text: province.shortName,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 26 * scale,
          color: const Color(0xFF20211D),
          fontWeight: FontWeight.w400,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();
    textPainter.paint(
      canvas,
      labelPoint - Offset(textPainter.width / 2, textPainter.height / 2),
    );
    textPainter.dispose();
  }

  @override
  bool shouldRepaint(covariant ProvinceMapPainter oldDelegate) =>
      oldDelegate.is3D != is3D ||
      oldDelegate.rotation != rotation ||
      oldDelegate.tilt != tilt ||
      oldDelegate.selected != selected;
}

Rect provinceMapRect(Size size, {double rotation = 0, double tilt = 1}) {
  // Fit one uniform scale, including the relief, even while rotating the map.
  final cosR = math.cos(rotation).abs();
  final sinR = math.sin(rotation).abs();
  final sourceWidth = sriLankaMapViewBox.width;
  final sourceHeight = sriLankaMapViewBox.height + 44;
  final projectedWidth = sourceWidth * cosR + sourceHeight * tilt * sinR;
  final projectedHeight = sourceWidth * sinR + sourceHeight * tilt * cosR;
  final scale = math.max(
    0.0,
    math.min(
      (size.width - 32) / projectedWidth,
      (size.height - 54) / projectedHeight,
    ),
  );
  return Rect.fromCenter(
    center: size.center(const Offset(0, -8)),
    width: sourceWidth * scale,
    height: sriLankaMapViewBox.height * scale,
  );
}

Offset provinceMapPoint(Offset point, Rect rect) => Offset(
  rect.left +
      (point.dx - sriLankaMapViewBox.left) *
          rect.width /
          sriLankaMapViewBox.width,
  rect.top +
      (point.dy - sriLankaMapViewBox.top) *
          rect.height /
          sriLankaMapViewBox.height,
);

Path provincePath(ProvinceData province, Rect rect) {
  return _transformReferencePath(_provinceSurfaces[province]!, rect);
}

Offset provinceSurfaceOffset(
  ProvinceData province,
  Rect rect, {
  ProvinceData? selected,
  bool is3D = true,
}) {
  if (!is3D || province != selected) return Offset.zero;
  final lift = _selectedLift * rect.width / sriLankaMapViewBox.width;
  return Offset(-lift * .14, -lift);
}

ProvinceData? provinceHitTest(
  Offset point,
  Rect rect, {
  ProvinceData? selected,
  bool is3D = true,
}) {
  // The raised face and its visible walls cover neighboring provinces.
  if (is3D && selected != null) {
    final surface = provincePath(selected, rect);
    final offset = provinceSurfaceOffset(selected, rect, selected: selected);
    final scale = rect.width / sriLankaMapViewBox.width;
    for (var depth = 0.0; depth <= _selectedLift + _baseDepth; depth++) {
      final position = offset + Offset(depth * .14 * scale, depth * scale);
      if (surface.contains(point - position)) return selected;
    }
  }
  for (final province in provinces.reversed) {
    if (provincePath(province, rect).contains(point)) return province;
  }
  return null;
}

Path _transformReferencePath(Path path, Rect rect) {
  final scaleX = rect.width / sriLankaMapViewBox.width;
  final scaleY = rect.height / sriLankaMapViewBox.height;
  return path.transform(
    Float64List.fromList([
      scaleX,
      0,
      0,
      0,
      0,
      scaleY,
      0,
      0,
      0,
      0,
      1,
      0,
      rect.left - sriLankaMapViewBox.left * scaleX,
      rect.top - sriLankaMapViewBox.top * scaleY,
      0,
      1,
    ]),
  );
}
