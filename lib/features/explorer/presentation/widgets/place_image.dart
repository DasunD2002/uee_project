import 'package:flutter/material.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) return const _ImageFallback();
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _ImageFallback(showProgress: true),
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFD7B99E), Color(0xFF657B6D)]),
    ),
    child: Center(
      child: showProgress
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.account_balance, color: Colors.white70, size: 40),
    ),
  );
}
