import 'package:kept/features/link_preview/application/link_preview_providers.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preview_refresher.g.dart';

/// Periodic price refresh, triggered by lists coming on screen: previews
/// whose slot looks due are offered to the server (which owns the clock and
/// claims the slot). One ask per link per app session, a few per load, so a
/// list never turns into a polling loop.
@Riverpod(keepAlive: true)
class PreviewRefresher extends _$PreviewRefresher {
  static const int maxPerLoad = 3;

  final Set<String> _asked = {};

  @override
  void build() {}

  /// Asks for the due previews and, when at least one came back different,
  /// invalidates [reload] so the list picks up the new price. The reload
  /// goes through this notifier's own ref: the screen that asked may be
  /// gone by then (a WidgetRef would throw).
  Future<bool> refreshDue(
    Iterable<LinkPreview> previews, {
    ProviderOrFamily? reload,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    final due = previews
        .where((p) => p.url != null && p.isPriceRefreshDue(clock))
        .where((p) => _asked.add(p.url!))
        .take(maxPerLoad)
        .toList();
    if (due.isEmpty) return false;
    final repository = ref.read(linkPreviewRepositoryProvider);
    var changed = false;
    for (final before in due) {
      final after = await repository.fetch(before.url!, refresh: true);
      if (after != null &&
          (after.price != before.price ||
              after.imagePath != before.imagePath ||
              after.title != before.title)) {
        changed = true;
      }
    }
    if (changed && reload != null) ref.invalidate(reload);
    return changed;
  }
}
