import 'package:flutter/material.dart';

class RootlyBackButton extends StatelessWidget {
  const RootlyBackButton({super.key, required this.fallbackRoute});

  final String fallbackRoute;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Back',
    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
    onPressed: () {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushReplacementNamed(fallbackRoute);
      }
    },
  );
}
