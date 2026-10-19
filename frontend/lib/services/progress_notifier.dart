import 'package:flutter/foundation.dart';

/// Fortschritts-Status für die Erkennung.
enum DetectionStep {
  idle,
  loadingImage,
  preprocessing,
  detectingWords,
  recognizingCharacters,
  spellchecking,
  done,
  error,
}

/// Detaillierter Fortschritts-Status mit Beschreibung.
class DetectionProgress {
  final DetectionStep step;
  final String message;
  final String? detail;
  final double progress; // 0.0 - 1.0
  final int? currentWord;
  final int? totalWords;

  const DetectionProgress({
    required this.step,
    required this.message,
    this.detail,
    this.progress = 0.0,
    this.currentWord,
    this.totalWords,
  });

  static const idle = DetectionProgress(
    step: DetectionStep.idle,
    message: 'Ready',
    progress: 0.0,
  );

  static const loadingImage = DetectionProgress(
    step: DetectionStep.loadingImage,
    message: 'Reading your handwriting...',
    progress: 0.05,
  );

  static const preprocessing = DetectionProgress(
    step: DetectionStep.preprocessing,
    message: 'Reading your handwriting...',
    progress: 0.10,
  );

  static const detectingWords = DetectionProgress(
    step: DetectionStep.detectingWords,
    message: 'Reading your handwriting...',
    progress: 0.20,
  );

  factory DetectionProgress.recognizingCharacter({
    required int current,
    required int total,
  }) {
    final pct = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    return DetectionProgress(
      step: DetectionStep.recognizingCharacters,
      message: 'Reading your handwriting...',
      progress: pct,
      currentWord: current,
      totalWords: total,
    );
  }

  static const spellchecking = DetectionProgress(
    step: DetectionStep.spellchecking,
    message: 'Checking spelling...',
    progress: 0.90,
  );

  static const done = DetectionProgress(
    step: DetectionStep.done,
    message: 'Done',
    progress: 1.0,
  );

  factory DetectionProgress.error(String errorMessage) {
    return DetectionProgress(
      step: DetectionStep.error,
      message: 'Something went wrong',
      detail: errorMessage,
      progress: 0.0,
    );
  }
}

/// Globaler Notifier für Fortschritts-Updates.
class ProgressNotifier extends ChangeNotifier {
  DetectionProgress _progress = DetectionProgress.idle;

  DetectionProgress get progress => _progress;

  void update(DetectionProgress newProgress) {
    _progress = newProgress;
    notifyListeners();
  }

  void reset() {
    _progress = DetectionProgress.idle;
    notifyListeners();
  }
}
