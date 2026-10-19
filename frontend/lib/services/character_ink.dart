import 'package:image/image.dart' as img;
import 'image_preprocessor.dart';

class CharacterInk {
  /// Horizontal foreground runs [x, y, length] in original image coordinates.
  static List<List<int>> extract(img.Image image, List<int> bbox) {
    final x1 = bbox[0].clamp(0, image.width);
    final y1 = bbox[1].clamp(0, image.height);
    final x2 = bbox[2].clamp(0, image.width);
    final y2 = bbox[3].clamp(0, image.height);
    if (x2 <= x1 || y2 <= y1) return [];
    final gray = img.grayscale(
        img.copyCrop(image, x: x1, y: y1, width: x2 - x1, height: y2 - y1));
    final threshold = ImagePreprocessor.otsuThreshold(gray).clamp(0, 200);
    final runs = <List<int>>[];
    for (var y = 0; y < gray.height; y++) {
      var start = -1;
      for (var x = 0; x <= gray.width; x++) {
        final ink = x < gray.width && gray.getPixel(x, y).r <= threshold;
        if (ink && start < 0) start = x;
        if (!ink && start >= 0) {
          runs.add([x1 + start, y1 + y, x - start]);
          start = -1;
        }
      }
    }
    return runs;
  }
}
