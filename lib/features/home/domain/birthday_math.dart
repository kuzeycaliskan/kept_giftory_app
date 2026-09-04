/// Pure date helpers for birthday countdowns (G-82, later G-62).
///
/// Feb-29 birthdays: `DateTime(year, 2, 29)` normalizes to Mar 1 in non-leap
/// years — that is the celebrated date here (unit-tested, keep G-62 in sync).
library;

/// Next occurrence of [birthday] on or after [today] (date-only comparison).
DateTime nextBirthday(DateTime birthday, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);
  var candidate = DateTime(today.year, birthday.month, birthday.day);
  if (candidate.isBefore(todayDate)) {
    candidate = DateTime(today.year + 1, birthday.month, birthday.day);
  }
  return candidate;
}

/// Whole days from [today] until the next occurrence of [birthday].
/// 0 means the birthday is today.
int daysUntilBirthday(DateTime birthday, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);
  return nextBirthday(birthday, today).difference(todayDate).inDays;
}
