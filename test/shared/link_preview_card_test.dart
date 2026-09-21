import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';

void main() {
  const priced = LinkPreview(
    id: 'lp',
    url: 'https://www.hepsiburada.com/x',
    title:
        'Clinique Moisture Surge™ 100 Saat Etkili Nemlendirici Yüz Kremi 15ml',
    site: 'www.hepsiburada.com',
    price: '₺511,00',
  );

  Future<void> pump(
    WidgetTester tester, {
    required double textScale,
    VoidCallback? onRemove,
  }) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ListView(
              children: [
                LinkPreviewCard(preview: priced, onRemove: onRemove),
                const LinkPreviewThumb(preview: priced),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a two-line title with site and price never overflows', (
    tester,
  ) async {
    await pump(tester, textScale: 1);
    expect(tester.takeException(), isNull);
    expect(find.text('₺511,00'), findsOneWidget);
    expect(find.text('www.hepsiburada.com'), findsOneWidget);
  });

  testWidgets('the card grows with 2x text instead of clipping', (
    tester,
  ) async {
    await pump(tester, textScale: 2, onRemove: () {});
    expect(tester.takeException(), isNull);
    final card = tester.getSize(find.byType(LinkPreviewCard));
    // Taller than the 84dp floor: the text column set the height.
    expect(card.height, greaterThan(84));
    expect(find.text('₺511,00'), findsOneWidget);
  });
}
