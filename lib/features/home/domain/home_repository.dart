import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/activity_item.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// Home dashboard data boundary (G-82).
abstract interface class HomeRepository {
  /// Accepted friends' upcoming birthdays, soonest first.
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({int limit = 10});
}

/// Activity panel boundary — mock-backed in V1, real event feed in V2 (G-210).
abstract interface class ActivityRepository {
  Future<Result<List<ActivityItem>>> recentActivity({int limit = 20});
}
