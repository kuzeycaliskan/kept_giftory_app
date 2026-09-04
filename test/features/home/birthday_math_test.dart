import 'package:flutter_test/flutter_test.dart';
import 'package:kept/features/home/domain/birthday_math.dart';

void main() {
  group('nextBirthday', () {
    test('later this year stays this year', () {
      final next = nextBirthday(DateTime(1995, 12, 20), DateTime(2026, 9, 4));
      expect(next, DateTime(2026, 12, 20));
    });

    test('already passed rolls to next year', () {
      final next = nextBirthday(DateTime(1995, 3, 10), DateTime(2026, 9, 4));
      expect(next, DateTime(2027, 3, 10));
    });

    test('today counts as today, not next year', () {
      final next = nextBirthday(DateTime(1995, 9, 4), DateTime(2026, 9, 4));
      expect(next, DateTime(2026, 9, 4));
    });

    test('Feb 29 normalizes to Mar 1 in non-leap years', () {
      final next = nextBirthday(DateTime(1996, 2, 29), DateTime(2026, 2, 10));
      expect(next, DateTime(2026, 3));
    });

    test('Feb 29 stays Feb 29 in leap years', () {
      final next = nextBirthday(DateTime(1996, 2, 29), DateTime(2028, 2, 10));
      expect(next, DateTime(2028, 2, 29));
    });
  });

  group('daysUntilBirthday', () {
    test('is 0 on the day', () {
      expect(
        daysUntilBirthday(DateTime(1995, 9, 4), DateTime(2026, 9, 4)),
        0,
      );
    });

    test('is 1 the day before', () {
      expect(
        daysUntilBirthday(DateTime(1995, 9, 5), DateTime(2026, 9, 4)),
        1,
      );
    });

    test('ignores the time of day', () {
      expect(
        daysUntilBirthday(
          DateTime(1995, 9, 5),
          DateTime(2026, 9, 4, 23, 59),
        ),
        1,
      );
    });
  });
}
