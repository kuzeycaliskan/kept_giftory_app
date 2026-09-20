import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kept/core/media/image_encoding.dart';

/// 2×1 image: left pixel red, right pixel blue.
Uint8List twoByOne() {
  final image = img.Image(width: 2, height: 1)
    ..setPixelRgb(0, 0, 255, 0, 0)
    ..setPixelRgb(1, 0, 0, 0, 255);
  return Uint8List.fromList(img.encodePng(image));
}

bool isRed(img.Pixel p) => p.r > 200 && p.b < 60;
bool isBlue(img.Pixel p) => p.b > 200 && p.r < 60;

void main() {
  test('flipHorizontal mirrors left and right', () {
    final out = img.decodeImage(flipHorizontal(twoByOne()))!;
    expect(out.width, 2);
    expect(isBlue(out.getPixel(0, 0)), isTrue);
    expect(isRed(out.getPixel(1, 0)), isTrue);
  });

  test('rotateQuarterTurn turns clockwise', () {
    final out = img.decodeImage(rotateQuarterTurn(twoByOne()))!;
    expect(out.width, 1);
    expect(out.height, 2);
    // Clockwise: the left (red) pixel ends up on top.
    expect(isRed(out.getPixel(0, 0)), isTrue);
    expect(isBlue(out.getPixel(0, 1)), isTrue);
  });

  test('normalizeOrientation keeps an untagged image as is', () {
    final out = img.decodeImage(normalizeOrientation(twoByOne()))!;
    expect(out.width, 2);
    expect(isRed(out.getPixel(0, 0)), isTrue);
    expect(isBlue(out.getPixel(1, 0)), isTrue);
  });
}
