import 'package:kept/core/error/result.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/profile/domain/special_day.dart';

/// The signed-in user's announced occasions (G-410b). Friends read them
/// through the Home repository; this is the owner's side.
abstract interface class SpecialDaysRepository {
  /// Mine, soonest first. Past days are not returned.
  Future<Result<List<SpecialDay>>> fetchMine();

  /// Announces one; the server refuses a past day, a birthday, and an
  /// "other" without a title.
  Future<Result<SpecialDay>> add({
    required EventKind kind,
    required DateTime day,
    String? title,
  });

  Future<Result<void>> remove(String id);
}
