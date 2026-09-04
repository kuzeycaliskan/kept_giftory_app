import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/activity_item.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// V1 activity source: canned sample items (per the G-82 decision the panel
/// ships as a scaffold with mock content; the real event feed lands in V2).
class MockActivityRepository implements ActivityRepository {
  const MockActivityRepository();

  @override
  Future<Result<List<ActivityItem>>> recentActivity({int limit = 20}) async {
    final now = DateTime.now();
    return Success([
      ActivityItem(
        id: 'mock-1',
        kind: ActivityKind.friendAccepted,
        text: 'Ali and Zeynep became friends',
        occurredAt: now.subtract(const Duration(hours: 2)),
      ),
      ActivityItem(
        id: 'mock-2',
        kind: ActivityKind.giftLogged,
        text: 'Mert logged a gift for Can',
        occurredAt: now.subtract(const Duration(days: 1)),
      ),
      ActivityItem(
        id: 'mock-3',
        kind: ActivityKind.birthdayReminder,
        text: "Selin's birthday is coming up",
        occurredAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }
}

/// Backend-less fallback so the app stays runnable without --dart-define
/// config (mirrors the router's guard).
class EmptyHomeRepository implements HomeRepository {
  const EmptyHomeRepository();

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async =>
      const Success([]);
}
