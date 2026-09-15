import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/shared/widgets/avatar_preview.dart';

void main() {
  testWidgets('avatar preview opens full-screen and dismisses on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showAvatarPreview(
                context,
                url: 'https://example.com/a.jpg',
                label: 'Kuzey',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Full-screen viewer with pinch-zoom and a close affordance.
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
