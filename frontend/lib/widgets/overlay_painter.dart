import 'package:flutter/material.dart';
import '../models/word_box.dart';
import '../services/spelling_feedback.dart';
import '../theme/app_theme.dart';

/// Colors only the ink belonging to suspected spelling differences.
class OverlayPainter extends CustomPainter {
  final List<WordBox> results;
  final Size imageSize;
  final Map<WordBox, String> corrections;
  final Rect? sourceRect;

  OverlayPainter(
      {required this.results,
      required this.imageSize,
      this.corrections = const {},
      this.sourceRect});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return;
    final crop = sourceRect ?? Offset.zero & imageSize;
    canvas.save();
    canvas.scale(size.width / crop.width, size.height / crop.height);
    canvas.translate(-crop.left, -crop.top);
    final paint = Paint()
      ..color = AppColors.error
      ..isAntiAlias = false;
    for (final word in results) {
      if (word.isCorrect) continue;
      final correction = corrections[word] ??
          (word.suggestions.isEmpty ? null : word.suggestions.first);
      if (correction == null) continue;
      final changed = SpellingFeedback.changedCharacters(word.text, correction);
      var offset = 0;
      for (final character in word.characters) {
        final suspect = List.generate(character.char.length, (i) => offset + i)
            .any(changed.contains);
        offset += character.char.length;
        if (!suspect) continue;
        for (final run in character.inkRuns) {
          canvas.drawRect(
              Rect.fromLTWH(
                  run[0].toDouble(), run[1].toDouble(), run[2].toDouble(), 1),
              paint);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OverlayPainter old) =>
      old.results != results ||
      old.imageSize != imageSize ||
      old.corrections != corrections ||
      old.sourceRect != sourceRect;
}
