import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:groundink/services/character_ink.dart';
import 'package:groundink/services/image_preprocessor.dart';

void main() {
  test('ink extraction excludes paper and neighboring glyphs', () {
    final image = img.Image(width: 30, height: 20);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    img.fillRect(image, x1: 5, y1: 5, x2: 7, y2: 14, color: img.ColorRgb8(0, 0, 0));
    img.fillRect(image, x1: 20, y1: 5, x2: 22, y2: 14, color: img.ColorRgb8(0, 0, 0));
    final runs = CharacterInk.extract(image, [2, 2, 12, 18]);
    expect(runs, hasLength(10));
    for (final run in runs) {
      expect(run[0], 5);
      expect(run[2], 3);
      expect(run[1], inInclusiveRange(5, 14));
    }
    expect(CharacterInk.extract(image, [12, 0, 18, 20]), isEmpty);
    expect(CharacterInk.extract(image, [40, 0, 50, 20]), isEmpty);
  });
  test('preprocessing offsets preserve original glyph coordinates', () {
    final source = img.Image(width: 80, height: 40);
    img.fill(source, color: img.ColorRgb8(240, 240, 240));
    img.fillRect(source, x1: 25, y1: 10, x2: 30, y2: 30, color: img.ColorRgb8(10, 10, 10));
    final (processed, offsetX, offsetY) = ImagePreprocessor.preprocessWithOffset(source);
    var count = 0;
    for (final pixel in processed) {
      if (pixel.r < 50) {
        count++;
        expect(pixel.x + offsetX, inInclusiveRange(25, 30));
        expect(pixel.y + offsetY, inInclusiveRange(10, 30));
      }
    }
    expect(count, greaterThan(0));
  });
}
