import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';

/// Debug-only sample profiles so the dev session renders full profile UIs.
class DevProfileRepository implements ProfileRepository {
  const DevProfileRepository();

  // Mutable so dev-session visibility edits survive screen rebuilds.
  static Profile _me = Profile(
    id: 'dev-me',
    username: 'you',
    displayName: 'You (dev)',
    birthday: DateTime(1998, 5, 5),
    occupation: 'Engineer',
    bio: 'Dev-session sample profile.',
  );

  static final Map<String, Profile> _others = {
    'dev-ali': Profile(
      id: 'dev-ali',
      username: 'ali',
      displayName: 'Ali',
      birthday: DateTime(1996, 9, 10),
      occupation: 'Designer',
    ),
    'dev-zeynep': Profile(
      id: 'dev-zeynep',
      username: 'zeynep',
      displayName: 'Zeynep',
      birthday: DateTime(1997, 12, 15),
    ),
    'dev-selin': const Profile(id: 'dev-selin', username: 'selin'),
    'dev-mert': const Profile(id: 'dev-mert', username: 'mert'),
  };

  @override
  Future<Result<Profile?>> fetchMyProfile() async => Success(_me);

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async =>
      Success(_others[profileId]);

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async =>
      const Success(true);

  @override
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async => Success(_me);

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async =>
      Success(profile);

  @override
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async {
    _me = _me.copyWith(
      profileVisibility: profile ?? _me.profileVisibility,
      wishlistVisibility: wishlist ?? _me.wishlistVisibility,
      giftHistoryVisibility: giftHistory ?? _me.giftHistoryVisibility,
    );
    return Success(_me);
  }

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const Success([]);
    return Success(
      _others.values
          .where(
            (p) =>
                p.username.contains(q) ||
                (p.displayName?.toLowerCase().contains(q) ?? false),
          )
          .map(_card)
          .toList(),
    );
  }

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async {
    final profile = _others[profileId];
    return Success(profile == null ? null : _card(profile));
  }

  static ProfileCard _card(Profile p) => ProfileCard(
    id: p.id,
    username: p.username,
    displayName: p.displayName,
    avatarUrl: p.avatarUrl,
  );
}

/// Backend-less fallback (no --dart-define config).
class EmptyProfileRepository implements ProfileRepository {
  const EmptyProfileRepository();

  @override
  Future<Result<Profile?>> fetchMyProfile() async => const Success(null);

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async =>
      const Success(null);

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async =>
      const Success(true);

  @override
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async => Success(Profile(id: 'noop', username: username));

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async =>
      Success(profile);

  @override
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async => const ResultFailure(AuthFailure('No backend configured'));

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async =>
      const Success([]);

  @override
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async =>
      const Success(null);
}
