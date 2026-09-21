import 'package:flutter_test/flutter_test.dart';
import 'package:kept/features/link_preview/data/og_extractor_script.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'the shared extractor ships as an asset and is a self-invoking script',
    () async {
      final source = await const OgExtractorScript().load();
      expect(source.trimLeft(), startsWith('//'));
      expect(source, contains('(function () {'));
      expect(source, contains('og:title'));
      expect(source.trimRight(), endsWith('})()'));
    },
  );
}
