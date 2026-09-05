import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/invite/application/invite_providers.dart';
import 'package:kept/features/invite/domain/invite_repository.dart';
import 'package:kept/features/invite/presentation/invite_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _FakeInviteRepository implements InviteRepository {
  _FakeInviteRepository();

  final String validCode = 'FRIEND01';

  @override
  Future<Result<String>> fetchMyCode() async => const Success('MYCODE12');

  @override
  Future<Result<RedeemedInvite>> redeem(String code) async {
    if (code.trim().toUpperCase() == validCode) {
      return const Success(
        RedeemedInvite(inviterId: 'x', label: 'Selin'),
      );
    }
    return const ResultFailure(ValidationFailure('invite_not_found'));
  }
}

void main() {
  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/invite',
      routes: [
        GoRoute(path: '/invite', builder: (_, __) => const InviteScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inviteRepositoryProvider.overrideWithValue(_FakeInviteRepository()),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows my code as text and QR', (tester) async {
    await pump(tester);

    expect(find.text('MYCODE12'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Share code'), findsOneWidget);
  });

  testWidgets('redeeming a valid code reports the new friend',
      (tester) async {
    await pump(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Invite code'),
      'friend01',
    );
    await tester.tap(find.text('Add friend'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Selin'), findsOneWidget);
  });

  testWidgets('an invalid code shows the friendly error', (tester) async {
    await pump(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Invite code'),
      'WRONG123',
    );
    await tester.tap(find.text('Add friend'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining("That code didn't work"),
      findsOneWidget,
    );
  });
}
