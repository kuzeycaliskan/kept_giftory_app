import 'package:flutter/foundation.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/link_preview/domain/link_preview_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Calls the `link-preview` edge function (SSRF guards, rate limit and the
/// cache all live server-side).
class SupabaseLinkPreviewRepository implements LinkPreviewRepository {
  SupabaseLinkPreviewRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<LinkPreview?> fetch(String url) async {
    final trimmed = url.trim();
    final parsed = Uri.tryParse(trimmed);
    final schemeOk =
        parsed != null && (parsed.isScheme('http') || parsed.isScheme('https'));
    if (!schemeOk) {
      return null;
    }
    try {
      final response = await _client.functions.invoke(
        'link-preview',
        body: {'url': trimmed},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final preview = data['preview'];
      if (preview is! Map<String, dynamic>) return null;
      return LinkPreview.fromJson(preview);
    } catch (e) {
      // Enhancement only — log and fall back to free text (design: G-211).
      debugPrint('link-preview fetch failed: $e');
      return null;
    }
  }
}
