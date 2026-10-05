/// What a gift event is for (G-410). Wire values match `event_kind`.
/// Birthday keeps every original behaviour (date from the profile,
/// automatic suggestions); the rest are opened by hand with a date.
enum EventKind {
  birthday('birthday'),
  newBaby('new_baby'),
  wedding('wedding'),
  newJob('new_job'),
  graduation('graduation'),
  newHome('new_home'),
  retirement('retirement'),
  other('other');

  const EventKind(this.wire);

  final String wire;

  static EventKind fromWire(String value) =>
      values.firstWhere((k) => k.wire == value, orElse: () => other);

  bool get isBirthday => this == EventKind.birthday;

  /// Only "other" carries a free title.
  bool get needsTitle => this == EventKind.other;
}

/// How far ahead a non-birthday event may be opened (server-enforced too).
const Duration eventMaxLeadTime = Duration(days: 92);

/// Title cap for an "other" event — mirrors `gift_events_title_len`.
const int eventTitleMaxLength = 60;
