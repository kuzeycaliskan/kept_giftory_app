import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// Home dashboard data boundary (G-82).
abstract interface class HomeRepository {
  /// Accepted friends' upcoming birthdays, soonest first.
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({int limit = 10});
}
