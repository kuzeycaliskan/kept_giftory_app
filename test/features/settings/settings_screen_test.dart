import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/auth_providers.dart';
import 'package:kept/features/auth/domain/auth_repository.dart';
import 'package:kept/features/settings/presentation/settings_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  bool deleteCalled = false;
  bool signOutCalled = false;
  Result<void> deleteResult = const Success(null);

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalled = true;
    return deleteResult;
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return const Success(null);
  }

  @override
  String? get currentUserId => 'u1';

  @override
  Stream<String?> authStateChanges() => const Stream.empty();

  @override
  Future<Result<String>> signInWithApple() async => const Success('u1');

  @override
  Future<Result<String>> signInWithGoogle() async => const Success('u1');
}

void main() {
  Future<void> pump(WidgetTester tester, _FakeAuthRepository repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sign out calls the repository', (tester) async {
    final repo = _FakeAuthRepository();
    await pump(tester, repo);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(repo.signOutCalled, isTrue);
  });

  testWidgets('delete account requires confirmation', (tester) async {
    final repo = _FakeAuthRepository();
    await pump(tester, repo);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);

    // Cancel → no deletion.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.deleteCalled, isFalse);

    // Confirm → deletion runs.
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();
    expect(repo.deleteCalled, isTrue);
  });

  testWidgets('deletion failure shows an error', (tester) async {
    final repo = _FakeAuthRepository()
      ..deleteResult = const ResultFailure(UnknownFailure('nope'));
    await pump(tester, repo);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not delete'), findsOneWidget);
  });
}
