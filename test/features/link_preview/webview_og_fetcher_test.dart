import 'package:flutter_test/flutter_test.dart';
import 'package:kept/features/link_preview/data/webview_og_fetcher.dart';

void main() {
  test('an about:blank read (no title) is not a result', () {
    // What Android hands back on the first onPageFinished after a redirect.
    expect(
      parseExtractorResult(
        '{"title":"","image":null,"price":null,"site":null}',
      ),
      isNull,
    );
  });

  test('platform-quoted and plain JSON both parse; blanks become null', () {
    const plain =
        '{"title":" Roborock ","image":"","price":"1.904,06 TL",'
        '"site":"www.amazon.com.tr"}';
    final expected = {
      'title': 'Roborock',
      'image': null,
      'price': '1.904,06 TL',
      'site': 'www.amazon.com.tr',
    };
    expect(parseExtractorResult(plain), expected);
    final quoted = '"${plain.replaceAll('"', r'\"')}"';
    expect(parseExtractorResult(quoted), expected);
  });
}
