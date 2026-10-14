import 'package:flutter/material.dart';
import 'place_image.dart';

/// Field notes accept both their existing asset paths and real region photos.
class RegionImage extends StatelessWidget {
  const RegionImage({super.key, required this.source, this.width, this.height});

  final String? source;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    final image = source?.trim() ?? '';
    final uri = Uri.tryParse(image);
    final isRemote = uri?.scheme == 'https' || uri?.scheme == 'http';
    return SizedBox(
      width: width,
      height: height,
      child: image.isEmpty || isRemote
          ? PlaceImage(url: image.isEmpty ? null : image)
          : Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const PlaceImage(url: null),
            ),
    );
  }
}
