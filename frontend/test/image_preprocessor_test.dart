import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:groundink/services/image_preprocessor.dart';

void main() {
  test('background normalization preserves ink and the source image', () {
    final source = img.Image(width: 80, height: 40);
    img.fill(source, color: img.ColorRgb8(240, 240, 240));
    img.fillRect(source, x1: 25, y1: 10, x2: 30, y2: 30,
        color: img.ColorRgb8(10, 10, 10));
    final original = source.getBytes().toList();

    final normalized = ImagePreprocessor.bgNormalize(source);

    expect(source.getBytes(), orderedEquals(original));
    expect(normalized.getPixel(27, 20).r, lessThan(50));
    expect(normalized.getPixel(5, 5).r, greaterThan(200));
  });
}
