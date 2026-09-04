import 'package:flutter/widgets.dart';
import 'package:kept/l10n/gen/app_localizations.dart';

export 'package:kept/l10n/gen/app_localizations.dart';

/// Ergonomic accessor: `context.l10n.homeFindFriends`.
///
/// House rule (CLAUDE.md §9): NO hardcoded user-facing strings in widgets —
/// every visible text goes through this. New strings land in
/// `lib/l10n/app_en.arb` (template) + `app_tr.arb` together.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
