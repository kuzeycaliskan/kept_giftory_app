import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/auth/presentation/sign_in_screen.dart';

void main() {
  testWidgets('dev-mode button enables the dev session (debug builds)', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    expect(container.read(devSessionProvider), isFalse);

    // Store requirement: the legal documents are one tap away at sign-in.
    expect(
      find.text(
        'By continuing you agree to our Terms of Use and Privacy Policy.',
      ),
      findsOneWidget,
    );
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);

    // Tests run in debug mode (and default to en), so the button is present.
    final devButton = find.text('Continue in dev mode (debug only)');
    expect(devButton, findsOneWidget);

    await tester.tap(devButton);
    await tester.pumpAndSettle();

    expect(container.read(devSessionProvider), isTrue);
    expect(find.text('home'), findsOneWidget);
  });
}
