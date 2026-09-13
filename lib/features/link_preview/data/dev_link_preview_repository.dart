import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/link_preview/domain/link_preview_repository.dart';

/// Debug-only sample previews so the forms are testable without a backend.
/// URLs containing "fail" return null (exercises the silent fallback).
class DevLinkPreviewRepository implements LinkPreviewRepository {
  const DevLinkPreviewRepository();

  @override
  Future<LinkPreview?> fetch(String url) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null || !parsed.hasScheme || url.contains('fail')) {
      return null;
    }
    return LinkPreview(
      id: 'dev-preview-${url.hashCode}',
      url: url,
      title: 'Örnek ürün — ${parsed.host}',
      price: '1.299,00 TL',
      site: parsed.host,
    );
  }
}

/// Backend-less fallback: previews simply never appear.
class EmptyLinkPreviewRepository implements LinkPreviewRepository {
  const EmptyLinkPreviewRepository();

  @override
  Future<LinkPreview?> fetch(String url) async => null;
}
