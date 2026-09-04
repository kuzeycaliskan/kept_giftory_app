/// Username rules (G-12). Mirrors the DB constraint
/// `^[A-Za-z0-9_]{3,20}$` — keep the two in sync.
abstract final class Username {
  static const int minLength = 3;
  static const int maxLength = 20;

  static final RegExp _pattern = RegExp(r'^[A-Za-z0-9_]{3,20}$');

  /// Null when valid; otherwise a machine-readable error code the UI localizes.
  static UsernameError? validate(String value) {
    if (value.length < minLength) return UsernameError.tooShort;
    if (value.length > maxLength) return UsernameError.tooLong;
    if (!_pattern.hasMatch(value)) return UsernameError.invalidCharacters;
    return null;
  }

  /// Canonical form used for uniqueness comparison (case-insensitive).
  static String normalize(String value) => value.toLowerCase();
}

enum UsernameError { tooShort, tooLong, invalidCharacters }
