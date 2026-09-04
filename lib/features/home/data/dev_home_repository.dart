import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/birthday_math.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// Sample upcoming birthdays for the debug-only dev session (no real auth),
/// so Home is visually testable end to end. Never used in release flows.
class DevHomeRepository implements HomeRepository {
  DevHomeRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async {
    final today = _now();
    UpcomingBirthday sample(String username, String name, int inDays) {
      final date = today.add(Duration(days: inDays));
      final birthday = DateTime(1995, date.month, date.day);
      return UpcomingBirthday(
        friendId: 'dev-$username',
        username: username,
        displayName: name,
        birthday: birthday,
        daysUntil: daysUntilBirthday(birthday, today),
      );
    }

    return Success([
      sample('ali', 'Ali', 0),
      sample('zeynep', 'Zeynep', 3),
      sample('mert', 'Mert', 12),
    ]);
  }
}
