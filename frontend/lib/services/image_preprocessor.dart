import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Image preprocessing für das Segmentierungs-Modell.
/// Implementiert bg_normalize, tight_crop, und white_pad.
class ImagePreprocessor {
  /// Konvertiert Bild zu Graustufen.
  static img.Image asGray(img.Image image) {
    if (image.numChannels == 1) return image;
    return img.grayscale(image);
  }

  /// Konvertiert Graustufen-Bild zu RGB.
  static img.Image asRgb(img.Image gray) {
    if (gray.numChannels >= 3) return gray;
    // Manuell Grau → RGB konvertieren
    final rgb = img.Image(width: gray.width, height: gray.height);
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final pixel = gray.getPixel(x, y);
        final g = pixel.r.toInt(); // Grauwert
        rgb.setPixelRgb(x, y, g, g, g);
      }
    }
    return rgb;
  }

  /// Perzentil-Berechnung für ein Array von Werten.
  static double percentile(List<int> values, double p) {
    if (values.isEmpty) return 0.0;
    final sorted = List<int>.from(values)..sort();
    final idx = ((p / 100.0) * (sorted.length - 1)).round();
    return sorted[idx.clamp(0, sorted.length - 1)].toDouble();
  }

  /// Contrast Stretching: dehnt Histogramm auf 0-255.
  static img.Image stretchContrast(img.Image gray) {
    // Sammle alle Grauwerte
    final values = <int>[];
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        values.add(gray.getPixel(x, y).r.toInt());
      }
    }

    final lo = percentile(values, 1.0);
    final hi = percentile(values, 99.0);
    if (hi <= lo + 1) return gray;

    final result = img.Image(width: gray.width, height: gray.height);
    final range = hi - lo;

    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final val = gray.getPixel(x, y).r.toInt();
        final stretched = ((val - lo) * 255.0 / range).clamp(0, 255).toInt();
        result.setPixelRgb(x, y, stretched, stretched, stretched);
      }
    }

    return result;
  }

  /// Background Normalization: entfernt ungleichmäßige Beleuchtung.
  static img.Image bgNormalize(img.Image gray) {
    // Berechne Sigma basierend auf Bildgröße
    final sigma = math.max(7, (math.min(gray.width, gray.height) / 3).round());

    // Gauss-Blur für Hintergrund-Schätzung
    // gaussianBlur mutates its input; keep the original ink for normalization.
    final bg = img.gaussianBlur(img.Image.from(gray), radius: sigma);

    // Division: gray / max(bg, 8) * 235
    final result = img.Image(width: gray.width, height: gray.height);
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final grayVal = gray.getPixel(x, y).r.toInt();
        final bgVal = math.max(bg.getPixel(x, y).r.toInt(), 8);
        final norm = (grayVal / bgVal * 235).clamp(0, 255).toInt();
        result.setPixelRgb(x, y, norm, norm, norm);
      }
    }

    return stretchContrast(result);
  }

  /// Berechnet Otsu-Threshold für ein Graustufenbild.
  static int otsuThreshold(img.Image gray) {
    // Histogramm erstellen
    final hist = List<int>.filled(256, 0);
    final total = gray.width * gray.height;

    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final val = gray.getPixel(x, y).r.toInt();
        hist[val]++;
      }
    }

    // Otsu's Methode: maximiere Between-Class Variance
    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * hist[i];
    }

    double sumB = 0;
    int wB = 0;
    double maxVar = 0;
    int threshold = 0;

    for (int t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;

      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final varBetween = wB * wF * (mB - mF) * (mB - mF);

      if (varBetween > maxVar) {
        maxVar = varBetween;
        threshold = t;
      }
    }

    return threshold;
  }

  /// Foreground-Maske: erkennt Vordergrund (Text).
  static List<List<bool>> foregroundMask(img.Image gray) {
    final h = gray.height;
    final w = gray.width;

    if (h < 3 || w < 3) {
      return List.generate(h, (_) => List.filled(w, true));
    }

    // Median der Randpixel als Hintergrund-Schätzung
    final border = <int>[];
    for (int x = 0; x < w; x++) {
      border.add(gray.getPixel(x, 0).r.toInt());
      border.add(gray.getPixel(x, h - 1).r.toInt());
    }
    for (int y = 1; y < h - 1; y++) {
      border.add(gray.getPixel(0, y).r.toInt());
      border.add(gray.getPixel(w - 1, y).r.toInt());
    }
    border.sort();
    final bg = border[border.length ~/ 2].toDouble();

    // Otsu-Threshold
    final blur = img.gaussianBlur(gray, radius: 1);
    final otsu = otsuThreshold(blur);

    // Maske erstellen
    final mask = List.generate(h, (_) => List.filled(w, false));

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final val = gray.getPixel(x, y).r.toInt();
        if (bg >= 128) {
          mask[y][x] = (val < bg - 12) || (val < otsu);
        } else {
          mask[y][x] = (val > bg + 12) || (val > otsu);
        }
      }
    }

    // Morphologisches Opening (vereinfacht)
    return _morphOpen(mask, 2);
  }

  /// Vereinfachtes morphologisches Opening.
  static List<List<bool>> _morphOpen(List<List<bool>> mask, int kernelSize) {
    final h = mask.length;
    if (h == 0) return mask;
    final w = mask[0].length;
    final pad = kernelSize ~/ 2;

    // Erosion
    final eroded = List.generate(h, (_) => List.filled(w, false));
    for (int y = pad; y < h - pad; y++) {
      for (int x = pad; x < w - pad; x++) {
        bool allTrue = true;
        outer:
        for (int ky = -pad; ky <= pad; ky++) {
          for (int kx = -pad; kx <= pad; kx++) {
            if (!mask[y + ky][x + kx]) {
              allTrue = false;
              break outer;
            }
          }
        }
        eroded[y][x] = allTrue;
      }
    }

    // Dilation
    final opened = List.generate(h, (_) => List.filled(w, false));
    for (int y = pad; y < h - pad; y++) {
      for (int x = pad; x < w - pad; x++) {
        outer:
        for (int ky = -pad; ky <= pad; ky++) {
          for (int kx = -pad; kx <= pad; kx++) {
            if (eroded[y + ky][x + kx]) {
              opened[y][x] = true;
              break outer;
            }
          }
        }
      }
    }

    return opened;
  }

  /// Tight Crop: schneidet das Bild auf den Vordergrund zu.
  static img.Image tightCropGray(img.Image gray, {int pad = 2}) {
    return _tightCropWithOffset(gray, pad: pad).$1;
  }

  static (img.Image, int, int) _tightCropWithOffset(img.Image gray,
      {int pad = 2}) {
    final mask = foregroundMask(gray);
    final h = gray.height;
    final w = gray.width;

    // Finde Bounding-Box des Vordergrunds
    int minX = w, maxX = 0, minY = h, maxY = 0;
    int count = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (mask[y][x]) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
          count++;
        }
      }
    }

    if (count < 5) return (gray, 0, 0);

    // Padding hinzufügen
    final x1 = math.max(0, minX - pad);
    final x2 = math.min(w, maxX + 1 + pad);
    final y1 = math.max(0, minY - pad);
    final y2 = math.min(h, maxY + 1 + pad);

    return (
      img.copyCrop(gray, x: x1, y: y1, width: x2 - x1, height: y2 - y1),
      x1,
      y1
    );
  }

  /// Fügt weißen Rand hinzu.
  static img.Image addWhitePad(img.Image gray, {int padX = 2, int padY = 2}) {
    final newW = gray.width + 2 * padX;
    final newH = gray.height + 2 * padY;
    final result = img.Image(width: newW, height: newH);

    // Mit Weiß füllen
    for (int y = 0; y < newH; y++) {
      for (int x = 0; x < newW; x++) {
        result.setPixelRgb(x, y, 255, 255, 255);
      }
    }

    // Original kopieren
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final pixel = gray.getPixel(x, y);
        result.setPixel(padX + x, padY + y, pixel);
      }
    }

    return result;
  }

  /// Haupt-Preprocessing-Pipeline für das Segmentierungsmodell.
  /// Entspricht preprocess_bg_norm_tight_pad2 aus Python.
  static img.Image preprocessForSegmentation(img.Image image) {
    return preprocessWithOffset(image).$1;
  }

  /// Offsets map processed coordinates back onto the unmodified word crop.
  static (img.Image, int, int) preprocessWithOffset(img.Image image) {
    // 1. Zu Graustufen konvertieren
    final gray = asGray(image);

    // 2. Background-Normalisierung
    final norm = bgNormalize(gray);

    // 3. Tight Crop mit Padding
    final (cropped, offsetX, offsetY) = _tightCropWithOffset(norm, pad: 2);

    // 4. Weißen Rand hinzufügen
    final padded = addWhitePad(cropped, padX: 2, padY: 2);

    // 5. Zurück zu RGB konvertieren
    return (asRgb(padded), offsetX - 2, offsetY - 2);
  }
}
