import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';

void main() {
  testWidgets('app boots into the Home dashboard (backend-less)',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KeptApp()));
    await tester.pumpAndSettle();

    // Backend-less runs use EmptyHomeRepository → empty upcoming state.
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('No upcoming birthdays yet'), findsOneWidget);
  });
}
