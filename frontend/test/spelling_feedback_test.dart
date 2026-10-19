import 'package:flutter_test/flutter_test.dart';
import 'package:groundink/services/spelling_feedback.dart';

void main() {
  test('only a substituted character is marked', () {
    expect(SpellingFeedback.changedCharacters('asbing', 'asking'), {2});
    expect(SpellingFeedback.changedCharacters('retura', 'return'), {5});
  });
  test('correct letters and case differences are not marked', () {
    expect(SpellingFeedback.changedCharacters('World', 'world'), isEmpty);
  });
  test('missing letters mark their nearest existing character', () {
    expect(SpellingFeedback.changedCharacters('kssed', 'kissed'), {1});
    expect(SpellingFeedback.changedCharacters('speling', 'spelling'), {4});
    expect(SpellingFeedback.changedCharacters('broter', 'brother'), {4});
    expect(SpellingFeedback.changedCharacters('scool', 'school'), {2});
  });
  test('the first visible mismatch is localized', () {
    expect(SpellingFeedback.changedCharacters('helllo', 'hello'), {3});
    expect(SpellingFeedback.changedCharacters('teh', 'the'), {1});
    expect(SpellingFeedback.changedCharacters('rabit', 'rabbit'), {3});
  });
  test('empty strings are handled', () {
    expect(SpellingFeedback.changedCharacters('', 'a'), isEmpty);
    expect(SpellingFeedback.changedCharacters('a', ''), {0});
  });
}
