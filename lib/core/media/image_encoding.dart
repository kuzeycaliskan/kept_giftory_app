import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_encoding.g.dart';

/// House upload format for user photos (moments, gift photos): EXIF-upright
/// JPEG, longest side ≤1080, quality 80 → ≈150–300 KB, well under the
/// buckets' 1 MB server cap.
abstract final class UploadImage {
  static const int maxSide = 1080;
  static const int jpegQuality = 80;
}

/// Bytes-in → upload JPEG-out, off the UI thread. A provider so widget
/// tests can skip the isolate hop (`compute` and fake async don't mix).
@Riverpod(keepAlive: true)
Future<Uint8List> Function(Uint8List) uploadEncoder(Ref ref) =>
    (bytes) => compute(toUploadJpeg, bytes);

/// Isolate entry: any decodable input → EXIF-upright JPEG within the cap.
@visibleForTesting
Uint8List toUploadJpeg(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw const FormatException('Undecodable image');
  }
  // Camera files carry orientation in EXIF; bake it so every viewer agrees.
  final upright = img.bakeOrientation(decoded);
  final longest = upright.width > upright.height
      ? upright.width
      : upright.height;
  final resized = longest > UploadImage.maxSide
      ? (upright.width >= upright.height
            ? img.copyResize(upright, width: UploadImage.maxSide)
            : img.copyResize(upright, height: UploadImage.maxSide))
      : upright;
  return Uint8List.fromList(
    img.encodeJpg(resized, quality: UploadImage.jpegQuality),
  );
}

/// Working-copy quality for edits before the final upload encode: high, so
/// rotate/flip/crop never compound visible loss.
const int _editQuality = 92;

Uint8List _encodeEdit(img.Image image) =>
    Uint8List.fromList(img.encodeJpg(image, quality: _editQuality));

img.Image _decodeOrThrow(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) throw const FormatException('Undecodable image');
  return decoded;
}

/// Bakes the EXIF orientation into the pixels and drops the tag. Front
/// cameras often store the shot with a mirrored orientation flag: viewers
/// honour it, pixel-level croppers don't — normalising first keeps what the
/// user frames and what gets saved identical (no surprise mirror).
Uint8List normalizeOrientation(Uint8List input) =>
    _encodeEdit(img.bakeOrientation(_decodeOrThrow(input)));

/// Rotates a quarter turn clockwise.
Uint8List rotateQuarterTurn(Uint8List input) =>
    _encodeEdit(img.copyRotate(_decodeOrThrow(input), angle: 90));

/// Mirrors left ↔ right.
Uint8List flipHorizontal(Uint8List input) =>
    _encodeEdit(img.flipHorizontal(_decodeOrThrow(input)));
