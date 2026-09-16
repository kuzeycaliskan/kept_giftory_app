import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';

void main() {
  // Backend-less runs skip the auth redirect, so the shell is directly
  // testable (see appRouter).
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KeptApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('boots into the shell with 4 destinations', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Gifts'), findsOneWidget);
    // The center slot is the camera (G-201); the compose flow is covered in
    // test/features/feed/feed_flow_test.dart.
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
  });

  testWidgets('switches tabs and keeps the shell', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Gifts'));
    await tester.pumpAndSettle();
    expect(find.text('No gifts logged yet'), findsOneWidget);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    // Backend-less: no profile row → neutral fallback.
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('activity bell opens the activity screen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet'), findsOneWidget);
  });
}
