import 'package:flutter_test/flutter_test.dart';
import 'package:kept/features/link_preview/domain/tracking_link.dart';

void main() {
  test('an Adjust interstitial unwraps to the shop page', () {
    final adj = Uri.parse(
      'https://p8zh.adj.st/mk12x3o?adjust_t=x'
      '&adjust_deeplink=ty%3A%2F%2F%3FPage%3DProduct'
      '&adjust_redirect=https%3A%2F%2Fwww.trendyol.com%2FMoliendo%2F'
      'kahve-p-859268209%3FboutiqueId%3D61',
    );
    expect(
      unwrapTrackingLink(adj).toString(),
      'https://www.trendyol.com/Moliendo/kahve-p-859268209?boutiqueId=61',
    );
  });

  test('falls back to adj_fallback and ignores non-web targets', () {
    expect(
      unwrapTrackingLink(
        Uri.parse(
          'https://app.adjust.com/abc?adj_fallback=https%3A%2F%2Fshop.test%2Fx',
        ),
      ).toString(),
      'https://shop.test/x',
    );
    expect(
      unwrapTrackingLink(
        Uri.parse('https://p8zh.adj.st/x?adjust_redirect=ty%3A%2F%2Fproduct'),
      ),
      isNull,
    );
    expect(unwrapTrackingLink(Uri.parse('https://www.trendyol.com/x')), isNull);
  });
}
