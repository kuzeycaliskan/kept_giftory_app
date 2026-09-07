import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/profile/presentation/user_profile_screen.dart';
import 'package:kept/features/safety/application/safety_providers.dart';
import 'package:kept/features/safety/domain/safety_repository.dart';
import 'package:kept/features/safety/presentation/blocked_users_screen.dart';

class _FakeSafetyRepository implements SafetyRepository {
  _FakeSafetyRepository({this.blocked = const []});

  List<ProfileCard> blocked;
  final List<String> blockedIds = [];
  final List<String> unblockedIds = [];
  final List<(String, ReportReason, String?)> reports = [];

  @override
  Future<Result<void>> block(String userId) async {
    blockedIds.add(userId);
    return const Success(null);
  }

  @override
  Future<Result<void>> unblock(String userId) async {
    unblockedIds.add(userId);
    return const Success(null);
  }

  @override
  Future<Result<List<ProfileCard>>> blockedUsers() async => Success(blocked);

  @override
  Future<Result<void>> report(
    String userId,
    ReportReason reason, {
    String? details,
  }) async {
    reports.add((userId, reason, details));
    return const Success(null);
  }
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester,
    _FakeSafetyRepository safety,
  ) async {
    // Backend-less: profile providers fall back to Empty* (null profile →
    // private/not-visible path), which is fine — the ⋯ menu lives in the
    // app bar regardless of body state.
    final router = GoRouter(
      initialLocation: '/users/ali-id?name=Ali',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Scaffold()),
        GoRoute(
          path: '/users/:uid',
          builder: (_, state) => UserProfileScreen(
            profileId: state.pathParameters['uid']!,
            label: state.uri.queryParameters['name'],
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [safetyRepositoryProvider.overrideWithValue(safety)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('blocking via the menu confirms, calls the repo and reports', (
    tester,
  ) async {
    final safety = _FakeSafetyRepository();
    await pumpProfile(tester, safety);

    await tester.tap(find.byType(PopupMenuButton<void>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();

    // Confirm dialog: cancel leaves the repo untouched.
    expect(find.text('Block this user?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(safety.blockedIds, isEmpty);

    // Again, but confirmed this time.
    await tester.tap(find.byType(PopupMenuButton<void>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block').last);
    await tester.pumpAndSettle();

    expect(safety.blockedIds, ['ali-id']);
    expect(find.text('User blocked.'), findsOneWidget);
  });

  testWidgets('report sheet submits the chosen reason and details', (
    tester,
  ) async {
    final safety = _FakeSafetyRepository();
    await pumpProfile(tester, safety);

    await tester.tap(find.byType(PopupMenuButton<void>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Harassment or bullying'));
    await tester.enterText(find.byType(TextField), 'threatening messages');
    await tester.tap(find.text('Send report'));
    await tester.pumpAndSettle();

    expect(safety.reports, [
      ('ali-id', ReportReason.harassment, 'threatening messages'),
    ]);
    expect(find.text("Thanks — we'll review this report."), findsOneWidget);
  });

  testWidgets('blocked users screen lists and unblocks', (tester) async {
    final safety = _FakeSafetyRepository(
      blocked: const [
        ProfileCard(id: 'ali-id', username: 'ali', displayName: 'Ali'),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [safetyRepositoryProvider.overrideWithValue(safety)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlockedUsersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ali'), findsOneWidget);
    await tester.tap(find.text('Unblock'));
    await tester.pumpAndSettle();
    expect(safety.unblockedIds, ['ali-id']);
  });

  testWidgets('empty block list shows the empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          safetyRepositoryProvider.overrideWithValue(_FakeSafetyRepository()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlockedUsersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("You haven't blocked anyone."), findsOneWidget);
  });
}
