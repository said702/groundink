import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groundink/models/word_box.dart';
import 'package:groundink/theme/app_theme.dart';
import 'package:groundink/widgets/overlay_painter.dart';

void main() {
  testWidgets('only suspect letter ink changes color', (tester) async {
    await tester.runAsync(() async {
      final word = WordBox(text: 'cot', bbox: [0, 0, 30, 10], confidence: 1,
        isCorrect: false, suggestions: ['cat'], characters: [
          for (var i = 0; i < 3; i++)
            CharacterResult(char: 'cot'[i], bbox: [i * 10, 0, i * 10 + 10, 10],
              contour: [], confidence: 1, inkRuns: [[i * 10 + 2, 2, 3]]),
        ]);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      for (var i = 0; i < 3; i++) {
        canvas.drawRect(Rect.fromLTWH(i * 10 + 2, 2, 3, 1), Paint()..color = Colors.black);
      }
      OverlayPainter(results: [word], imageSize: const Size(30, 10)).paint(canvas, const Size(30, 10));
      final picture = recorder.endRecording();
      final image = await picture.toImage(30, 10);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      int pixel(int x, int y) => bytes.getUint32((y * 30 + x) * 4);
      expect(pixel(2, 2), 0x000000ff);
      expect(pixel(22, 2), 0x000000ff);
      final red = AppColors.error.toARGB32();
      expect(pixel(12, 2), ((red & 0xffffff) << 8) | 0xff);
      expect(pixel(12, 3), 0xffffffff);
      expect(pixel(0, 0), 0xffffffff);
      image.dispose();
      picture.dispose();
    });
  });
}
