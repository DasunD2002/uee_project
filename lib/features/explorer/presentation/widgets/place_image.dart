import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlaceImage extends StatefulWidget {
  const PlaceImage({super.key, required this.url});
  final String? url;

  /// Keep old saved photo references usable with Wikimedia's current sizes.
  static String displayUrl(String source) {
    final uri = Uri.tryParse(source.trim());
    if (uri == null) return source;
    if (uri.host == 'commons.wikimedia.org' &&
        uri.path.startsWith('/wiki/Special:FilePath/')) {
      return uri
          .replace(
            scheme: 'https',
            queryParameters: {...uri.queryParameters, 'width': '960'},
          )
          .toString();
    }
    if ((uri.host == 'upload.wikimedia.org' ||
            uri.host == 'thumb.wikimedia.org') &&
        uri.path.startsWith('/wikipedia/') &&
        uri.path.contains('/thumb/')) {
      final path = uri.path.replaceFirstMapped(
        RegExp(r'/(\d+)px-([^/]+)$'),
        (match) => '/960px-${match[2]}',
      );
      return uri
          .replace(scheme: 'https', host: 'thumb.wikimedia.org', path: path)
          .toString();
    }
    return source;
  }

  @override
  State<PlaceImage> createState() => _PlaceImageState();
}

class _PlaceImageState extends State<PlaceImage> {
  int _attempt = 0;

  Map<String, String>? _headers(String url) {
    final host = Uri.tryParse(url)?.host;
    if (kIsWeb ||
        host == null ||
        !(host == 'commons.wikimedia.org' ||
            host == 'upload.wikimedia.org' ||
            host == 'thumb.wikimedia.org')) {
      return null;
    }
    return const {'User-Agent': 'Rootly/1.0 (Sri Lanka heritage explorer)'};
  }

  Future<void> _retry(String url) async {
    await NetworkImage(url, headers: _headers(url)).evict();
    if (mounted) setState(() => _attempt++);
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.url?.trim();
    if (source == null || source.isEmpty) return const SizedBox.shrink();
    final url = PlaceImage.displayUrl(source);
    return Image.network(
      url,
      key: ValueKey('$url:$_attempt'),
      headers: _headers(url),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (_, _, _) => Center(
        child: TextButton(
          onPressed: () => _retry(url),
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: .9),
          ),
          child: const Text('Retry photo'),
        ),
      ),
    );
  }
}
