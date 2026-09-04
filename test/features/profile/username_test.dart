import 'package:flutter_test/flutter_test.dart';
import 'package:kept/features/profile/domain/username.dart';

void main() {
  group('Username.validate', () {
    test('accepts valid usernames', () {
      expect(Username.validate('kuzey'), isNull);
      expect(Username.validate('Kuzey_42'), isNull);
      expect(Username.validate('abc'), isNull);
      expect(Username.validate('a' * 20), isNull);
    });

    test('rejects too short', () {
      expect(Username.validate('ab'), UsernameError.tooShort);
      expect(Username.validate(''), UsernameError.tooShort);
    });

    test('rejects too long', () {
      expect(Username.validate('a' * 21), UsernameError.tooLong);
    });

    test('rejects invalid characters', () {
      expect(Username.validate('kuzey!'), UsernameError.invalidCharacters);
      expect(Username.validate('küzey'), UsernameError.invalidCharacters);
      expect(Username.validate('ku zey'), UsernameError.invalidCharacters);
      expect(Username.validate('kuzey.c'), UsernameError.invalidCharacters);
    });

    test('normalize lowercases (matches DB citext-style uniqueness)', () {
      expect(Username.normalize('KuZeY'), 'kuzey');
    });
  });
}
