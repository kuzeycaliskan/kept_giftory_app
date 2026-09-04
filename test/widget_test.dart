import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app.dart';

void main() {
  testWidgets('app boots to the Home placeholder', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KeptApp()));
    await tester.pumpAndSettle();

    expect(find.text('Kept — skeleton ready'), findsOneWidget);
  });
}
