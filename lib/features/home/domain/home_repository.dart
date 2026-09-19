import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// Home dashboard data boundary (G-82).
abstract interface class HomeRepository {
  /// Accepted friends' upcoming birthdays, soonest first.
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({int limit = 10});

  /// Friends' most recent wishlist additions (visibility via RLS).
  Future<Result<List<FriendWishlistItem>>> recentFriendWishlistItems({
    int limit = 6,
  });

  /// My real social events: new friendships + gifts logged for me
  /// (surprises stay RLS-hidden until revealed), newest first.
  Future<Result<List<HomeEvent>>> recentEvents({int limit = 6});

  /// Pending-surprise teaser for the caller; null when nothing is pending.
  Future<Result<SurpriseTeaser?>> surpriseTeaser();
}
