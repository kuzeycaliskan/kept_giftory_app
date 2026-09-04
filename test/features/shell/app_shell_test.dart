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
    expect(find.text('Friends'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Kept — skeleton ready'), findsOneWidget);
  });

  testWidgets('Add opens the quick-add sheet instead of navigating',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Log a gift'), findsOneWidget);
    expect(find.text('Add to wishlist'), findsOneWidget);
    // Shell is still on Home underneath.
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('activity bell opens the activity screen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet'), findsOneWidget);
  });
}
