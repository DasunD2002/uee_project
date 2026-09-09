import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:file_selector/file_selector.dart';

Future<Uint8List?> pickProfilePhoto({bool isCover = false}) async {
  final file = await openFile(
    acceptedTypeGroups: [
      const XTypeGroup(
        label: 'Photos',
        extensions: ['jpg', 'jpeg', 'png'],
        mimeTypes: ['image/jpeg', 'image/png'],
        uniformTypeIdentifiers: ['public.jpeg', 'public.png'],
      ),
    ],
  );
  if (file == null) return null;
  if (await file.length() > 10 * 1024 * 1024) {
    throw const FormatException('Choose a photo smaller than 10 MB.');
  }
  // Resize before storing so camera photos do not fill local preferences.
  final codec = await ui.instantiateImageCodec(
    await file.readAsBytes(),
    targetWidth: isCover ? 1200 : 400,
    allowUpscaling: false,
  );
  try {
    final frame = await codec.getNextFrame();
    try {
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const FormatException('Could not read this photo.');
      }
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (base64Encode(bytes).length > 2 * 1024 * 1024) {
        throw const FormatException('Choose a smaller photo.');
      }
      return bytes;
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}
