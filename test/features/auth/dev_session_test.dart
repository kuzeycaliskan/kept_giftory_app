import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/auth/presentation/sign_in_screen.dart';

void main() {
  testWidgets('dev-mode button enables the dev session (debug builds)',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (_, __) => const SignInScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(container.read(devSessionProvider), isFalse);

    // Tests run in debug mode, so the button is present.
    final devButton = find.text('Continue in dev mode (debug only)');
    expect(devButton, findsOneWidget);

    await tester.tap(devButton);
    await tester.pumpAndSettle();

    expect(container.read(devSessionProvider), isTrue);
    expect(find.text('home'), findsOneWidget);
  });
}
