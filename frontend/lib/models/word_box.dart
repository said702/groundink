// Recognized character and its location in the source image.
class CharacterResult {
  final String char;
  final List<int> bbox;
  final List<List<int>> contour;
  final double confidence;

  /// Segmentierungs-Maske (Werte 0..1), in Wort-Crop-Koordinaten.
  /// May be null when the model does not return a mask.
  final List<List<double>>? mask;
  final int? maskW;
  final int? maskH;
  final List<List<int>> inkRuns;

  CharacterResult({
    required this.char,
    required this.bbox,
    required this.contour,
    required this.confidence,
    this.mask,
    this.maskW,
    this.maskH,
    this.inkRuns = const [],
  });

  factory CharacterResult.fromJson(Map<String, dynamic> json) {
    return CharacterResult(
      char: json['char'] as String? ?? '?',
      bbox: (json['bbox'] as List?)?.map((e) => (e as num).toInt()).toList() ??
          [],
      contour: (json['contour'] as List?)
              ?.map(
                  (pt) => (pt as List).map((e) => (e as num).toInt()).toList())
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      mask: (json['mask'] as List?)
          ?.map(
              (row) => (row as List).map((e) => (e as num).toDouble()).toList())
          .toList(),
      maskW: json['maskW'] as int?,
      maskH: json['maskH'] as int?,
    );
  }
}

/// Recognized word with spelling feedback and character locations.
class WordBox {
  final String text;
  final List<int> bbox; // [x1, y1, x2, y2]
  final double confidence;
  final bool isCorrect;
  final List<String> suggestions;
  final List<CharacterResult> characters;

  WordBox({
    required this.text,
    required this.bbox,
    required this.confidence,
    required this.isCorrect,
    required this.suggestions,
    required this.characters,
  });

  factory WordBox.fromJson(Map<String, dynamic> json) {
    return WordBox(
      text: json['text'] as String? ?? '',
      bbox: (json['bbox'] as List?)?.map((e) => (e as num).toInt()).toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isCorrect: json['is_correct'] as bool? ?? false,
      suggestions:
          (json['suggestions'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      characters: (json['characters'] as List?)
              ?.map((e) => CharacterResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
