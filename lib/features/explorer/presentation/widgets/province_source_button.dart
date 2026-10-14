import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class ProvinceSourceButton extends StatelessWidget {
  const ProvinceSourceButton({
    super.key,
    this.sourceUrl,
    this.imageSourceUrl,
    this.wikipediaUrl,
  });

  final String? sourceUrl, imageSourceUrl, wikipediaUrl;

  @override
  Widget build(BuildContext context) {
    final sources = <String, String>{
      'Place data · Wikidata': ?sourceUrl,
      'Photo page and licence': ?imageSourceUrl,
      'Read more · Wikipedia': ?wikipediaUrl,
    };
    if (sources.isEmpty) return const SizedBox.shrink();
    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: AppColors.brown),
      icon: const Icon(Icons.info_outline, size: 14),
      label: const Text(
        'Sources & photo credits',
        style: TextStyle(fontSize: 10),
      ),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sources & photo credits'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in sources.entries) ...[
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    entry.value,
                    style: const TextStyle(fontSize: 12),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: entry.value));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Source link copied.')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copy link'),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
