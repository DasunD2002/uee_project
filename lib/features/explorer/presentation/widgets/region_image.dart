import 'package:flutter/material.dart';
import 'place_image.dart';

/// Field notes accept both their existing asset paths and real region photos.
class RegionImage extends StatelessWidget {
  const RegionImage({super.key, required this.source, this.width, this.height});

  final String? source;
  final double? width, height;

  static String _displayUrl(String source) {
    final uri = Uri.tryParse(source);
    if (uri == null ||
        uri.host != 'commons.wikimedia.org' ||
        !uri.path.startsWith('/wiki/Special:FilePath/')) {
      return source;
    }
    return uri
        .replace(queryParameters: {...uri.queryParameters, 'width': '900'})
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    final image = source?.trim() ?? '';
    final uri = Uri.tryParse(image);
    final isRemote = uri?.scheme == 'https' || uri?.scheme == 'http';
    return SizedBox(
      width: width,
      height: height,
      child: image.isEmpty || isRemote
          ? PlaceImage(url: image.isEmpty ? null : _displayUrl(image))
          : Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const PlaceImage(url: null),
            ),
    );
  }
}
