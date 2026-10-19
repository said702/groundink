/// Aligns a recognized word with a proposed correction.
class SpellingFeedback {
  static Set<int> changedCharacters(String recognized, String correction) {
    final source = recognized.toLowerCase();
    final target = correction.toLowerCase();
    var index = 0;
    while (index < source.length &&
        index < target.length &&
        source[index] == target[index]) {
      // An extra repeated character is the first visible error even though
      // the duplicated character itself still matches at this position.
      if (index + 1 < source.length &&
          source[index] == source[index + 1] &&
          (index + 1 >= target.length ||
              source[index + 1] != target[index + 1])) {
        return {index};
      }
      index++;
    }

    // The target may contain an inserted letter. There is no ink for that
    // letter, so mark the first existing character that is displaced by it.
    if (index < source.length) return {index};
    return <int>{};
  }
}
