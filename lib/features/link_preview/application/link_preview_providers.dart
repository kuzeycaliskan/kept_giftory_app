import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/link_preview/data/dev_link_preview_repository.dart';
import 'package:kept/features/link_preview/data/supabase_link_preview_repository.dart';
import 'package:kept/features/link_preview/domain/link_preview_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_preview_providers.g.dart';

@Riverpod(keepAlive: true)
LinkPreviewRepository linkPreviewRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyLinkPreviewRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const DevLinkPreviewRepository();
  }
  return SupabaseLinkPreviewRepository(client);
}
