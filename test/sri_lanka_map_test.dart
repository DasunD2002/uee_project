import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uee_project/features/explorer/presentation/sri_lanka_3d_map_screen.dart';
import 'package:uee_project/features/explorer/presentation/sri_lanka_map_geometry.dart';
import 'package:uee_project/features/explorer/presentation/sri_lanka_map_painter.dart';

final _mapFinder = find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.painter is ProvinceMapPainter,
);

ProvinceMapPainter _painter(WidgetTester tester) =>
    tester.widget<CustomPaint>(_mapFinder).painter! as ProvinceMapPainter;

Offset _provinceTapPosition(WidgetTester tester, ProvinceData province) {
  final painter = _painter(tester);
  final rect = _mapRect(tester);
  return _screenPosition(
    tester,
    provinceMapPoint(province.label, rect) +
        provinceSurfaceOffset(
          province,
          rect,
          selected: painter.selected,
          is3D: painter.is3D,
        ),
  );
}

Rect _mapRect(WidgetTester tester) {
  final painter = _painter(tester);
  final size = tester.getSize(_mapFinder);
  return provinceMapRect(
    size,
    rotation: painter.rotation,
    tilt: painter.is3D ? painter.tilt : 1,
  );
}

Offset _screenPosition(WidgetTester tester, Offset mapPoint) {
  final painter = _painter(tester);
  final size = tester.getSize(_mapFinder);
  final center = size.center(Offset.zero);
  final relative = mapPoint - center;
  final tiltedY = relative.dy * (painter.is3D ? painter.tilt : 1);
  final rotated = Offset(
    relative.dx * math.cos(painter.rotation) -
        tiltedY * math.sin(painter.rotation),
    relative.dx * math.sin(painter.rotation) +
        tiltedY * math.cos(painter.rotation),
  );
  return tester.getTopLeft(_mapFinder) + center + rotated;
}

void _expectRaisedProvince(WidgetTester tester, ProvinceData? selected) {
  final painter = _painter(tester);
  expect(painter.selected, selected);
  for (final province in provinces) {
    final offset = provinceSurfaceOffset(
      province,
      _mapRect(tester),
      selected: painter.selected,
      is3D: painter.is3D,
    );
    if (province == selected && painter.is3D) {
      expect(offset.dy, lessThan(0), reason: province.name);
    } else {
      expect(offset, Offset.zero, reason: province.name);
    }
  }
}

// Find the part of a raised top face that lies outside its original footprint.
// A tap here catches hit testing that still uses the unraised province path.
Offset _exposedRaisedTopPoint(ProvinceData province, Rect rect) {
  final original = provincePath(province, rect);
  final shifted = original.shift(
    provinceSurfaceOffset(province, rect, selected: province),
  );
  final bounds = shifted.getBounds();
  for (var y = bounds.top + 2; y < bounds.bottom; y += 2) {
    for (var x = bounds.left + 2; x < bounds.right; x += 2) {
      final point = Offset(x, y);
      if (!original.contains(point) &&
          [
            point,
            point + const Offset(1, 0),
            point - const Offset(1, 0),
            point + const Offset(0, 1),
            point - const Offset(0, 1),
          ].every(shifted.contains)) {
        return point;
      }
    }
  }
  throw StateError('No exposed raised top face for ${province.name}');
}

Future<void> _pumpMap(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: SriLanka3DMapScreen()));
  await tester.pumpAndSettle();
}

Future<void> _selectEveryProvince(WidgetTester tester) async {
  for (final province in provinces) {
    await tester.tapAt(_provinceTapPosition(tester, province));
    await tester.pumpAndSettle();
    expect(_painter(tester).selected?.name, province.name);
    expect(find.text(province.name), findsOneWidget);
    expect(tester.takeException(), isNull, reason: province.name);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(_painter(tester).selected, isNull);
  }
}

double _cross(Offset a, Offset b, Offset c) =>
    (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);

bool _edgesCross(Offset a, Offset b, Offset c, Offset d) =>
    _cross(a, b, c) * _cross(a, b, d) < 0 &&
    _cross(c, d, a) * _cross(c, d, b) < 0;

void main() {
  test('all provinces start level and only the selected province rises', () {
    for (final rect in [
      sriLankaMapViewBox,
      provinceMapRect(const Size(336, 460)),
    ]) {
      for (final province in provinces) {
        expect(
          provinceSurfaceOffset(province, rect),
          Offset.zero,
          reason: '${province.name} must not have permanent elevation',
        );
        for (final selected in provinces) {
          final offset = provinceSurfaceOffset(
            province,
            rect,
            selected: selected,
          );
          if (province == selected) {
            expect(offset.dy, lessThan(0), reason: province.name);
          } else {
            expect(offset, Offset.zero, reason: province.name);
          }
          expect(
            provinceSurfaceOffset(
              province,
              rect,
              selected: selected,
              is3D: false,
            ),
            Offset.zero,
            reason: '2D faces stay flat',
          );
        }
      }
    }
  });

  test('raised top faces receive taps outside their original footprints', () {
    final rect = provinceMapRect(const Size(700, 900));
    for (final province in provinces) {
      final point = _exposedRaisedTopPoint(province, rect);
      expect(provincePath(province, rect).contains(point), isFalse);
      expect(
        provinceHitTest(point, rect, selected: province),
        province,
        reason: province.name,
      );
      expect(
        provinceHitTest(point, rect, selected: province, is3D: false),
        isNot(province),
        reason: '2D hit testing must use the original face',
      );
    }
  });

  test('each province label belongs only to its own geographic region', () {
    expect(provinces, hasLength(9));
    for (final size in [const Size(336, 460), const Size(1000, 410)]) {
      final rect = provinceMapRect(size);
      expect(
        rect.width / rect.height,
        closeTo(sriLankaMapViewBox.width / sriLankaMapViewBox.height, .001),
      );
      for (final province in provinces) {
        final point = provinceMapPoint(province.label, rect);
        final containing = provinces
            .where((candidate) => provincePath(candidate, rect).contains(point))
            .map((candidate) => candidate.name);
        expect(containing, [province.name], reason: province.name);
      }
    }
  });

  test('Northern offshore islands form separate selectable contours', () {
    final northern = provinces.singleWhere(
      (province) => province.name == 'Northern Province',
    );
    final rect = provinceMapRect(const Size(650, 990));
    final path = provincePath(northern, rect);
    expect(path.computeMetrics().length, greaterThan(1));
    expect(
      path.contains(provinceMapPoint(const Offset(252, 95), rect)),
      isTrue,
    );
    expect(
      path.contains(provinceMapPoint(const Offset(240, 150), rect)),
      isFalse,
    );
  });

  test('coastal cutouts remain water even where they cross the coastline', () {
    for (final province in provinces) {
      final surface = provincePath(province, sriLankaMapViewBox);
      for (final cutout in province.cutouts) {
        final water = Path()..addPolygon(cutout, true);
        final bounds = water.getBounds();
        for (var x = bounds.left + .37; x < bounds.right; x += 1) {
          for (var y = bounds.top + .37; y < bounds.bottom; y += 1) {
            final point = Offset(x, y);
            // Boundary inclusion can change with float rounding in Path.combine.
            // Sample only points strictly inside the water polygon.
            if (![
              point,
              point + const Offset(.02, 0),
              point - const Offset(.02, 0),
              point + const Offset(0, .02),
              point - const Offset(0, .02),
            ].every(water.contains)) {
              continue;
            }
            expect(
              surface.contains(point),
              isFalse,
              reason:
                  '${province.name} paints land inside a coastal cutout at $point',
            );
          }
        }
      }
    }
    final northern = provinces.singleWhere(
      (province) => province.name == 'Northern Province',
    );
    expect(
      provincePath(
        northern,
        sriLankaMapViewBox,
      ).contains(const Offset(541, 144)),
      isFalse,
    );
  });

  test('province contours do not cross themselves', () {
    for (final province in provinces) {
      for (final ring in [
        province.points,
        ...province.islands,
        ...province.cutouts,
      ]) {
        for (var i = 0; i < ring.length; i++) {
          for (var j = i + 2; j < ring.length; j++) {
            if (i == 0 && j == ring.length - 1) continue;
            expect(
              _edgesCross(
                ring[i],
                ring[(i + 1) % ring.length],
                ring[j],
                ring[(j + 1) % ring.length],
              ),
              isFalse,
              reason: '${province.name}, edges $i and $j',
            );
          }
        }
      }
    }
  });

  for (final size in [const Size(360, 640), const Size(1280, 720)]) {
    testWidgets('all provinces can be selected at ${size.width.toInt()}px', (
      tester,
    ) async {
      await _pumpMap(tester, size);
      expect(tester.takeException(), isNull);
      await _selectEveryProvince(tester);
    });
  }

  testWidgets(
    'switching provinces lowers the previous one and tapping again clears',
    (tester) async {
      await _pumpMap(tester, const Size(1280, 720));
      _expectRaisedProvince(tester, null);
      for (final province in provinces) {
        await tester.tapAt(_provinceTapPosition(tester, province));
        await tester.pumpAndSettle();
        _expectRaisedProvince(tester, province);
      }
      await tester.tapAt(_provinceTapPosition(tester, provinces.last));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, null);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'closing the card or tapping the sea lowers the selected province',
    (tester) async {
      await _pumpMap(tester, const Size(1280, 720));
      final uva = provinces.singleWhere(
        (province) => province.name == 'Uva Province',
      );
      await tester.tapAt(_provinceTapPosition(tester, uva));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, uva);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, null);

      await tester.tapAt(_provinceTapPosition(tester, uva));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, uva);
      await tester.tapAt(tester.getTopLeft(_mapFinder) + const Offset(8, 8));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, null);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('rotated raised faces stay tappable at their displaced edges', (
    tester,
  ) async {
    await _pumpMap(tester, const Size(1280, 720));
    await tester.drag(_mapFinder, const Offset(55, -65));
    await tester.pumpAndSettle();
    expect(_painter(tester).rotation.abs(), greaterThan(.02));
    expect(_painter(tester).tilt, lessThan(1));
    for (final province in provinces) {
      await tester.tapAt(_provinceTapPosition(tester, province));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, province);
      final point = _exposedRaisedTopPoint(province, _mapRect(tester));
      await tester.tapAt(_screenPosition(tester, point));
      await tester.pumpAndSettle();
      _expectRaisedProvince(tester, null);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('province selection follows rotation and the 2D toggle', (
    tester,
  ) async {
    await _pumpMap(tester, const Size(390, 844));
    await tester.drag(_mapFinder, const Offset(55, -65));
    await tester.pumpAndSettle();
    expect(_painter(tester).rotation.abs(), greaterThan(.02));
    expect(_painter(tester).tilt, lessThan(1));
    await _selectEveryProvince(tester);

    await tester.tap(find.text('2D Map'));
    await tester.pumpAndSettle();
    expect(_painter(tester).is3D, isFalse);
    expect(_painter(tester).rotation, 0);
    await _selectEveryProvince(tester);

    await tester.tap(find.text('3D Map'));
    await tester.pumpAndSettle();
    expect(_painter(tester).is3D, isTrue);
    expect(_painter(tester).rotation, 0);
    expect(_painter(tester).tilt, 1);
    expect(tester.takeException(), isNull);
  });
}
