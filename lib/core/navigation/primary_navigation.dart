import 'package:flutter/material.dart';

void navigateToPrimaryDestination(
  BuildContext context,
  int index, {
  int? currentIndex,
}) {
  if (index == currentIndex) return;
  final route = switch (index) {
    0 => '/home',
    1 => '/explorer',
    2 => '/questions',
    3 => '/capsule',
    _ => null,
  };
  if (route == null) return;
  Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
}
