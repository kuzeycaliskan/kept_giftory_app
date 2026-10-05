import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/profile/data/supabase_special_days_repository.dart';
import 'package:kept/features/profile/domain/special_day.dart';
import 'package:kept/features/profile/domain/special_days_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'special_days_providers.g.dart';

@Riverpod(keepAlive: true)
SpecialDaysRepository specialDaysRepository(Ref ref) =>
    SupabaseSpecialDaysRepository(ref.watch(supabaseClientProvider));

/// My announced occasions, soonest first (G-410b).
@riverpod
Future<List<SpecialDay>> mySpecialDays(Ref ref) async {
  final result = await ref.watch(specialDaysRepositoryProvider).fetchMine();
  return result.when(success: (d) => d, failure: (f) => throw f);
}

// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
@Riverpod(keepAlive: true)
class SpecialDaysController extends _$SpecialDaysController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Failure?> add({
    required EventKind kind,
    required DateTime day,
    String? title,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(specialDaysRepositoryProvider)
        .add(kind: kind, day: day, title: title);
    return _finish<SpecialDay>(result);
  }

  Future<Failure?> remove(String id) async {
    state = const AsyncLoading();
    final result = await ref.read(specialDaysRepositoryProvider).remove(id);
    return _finish<void>(result);
  }

  Failure? _finish<T>(Result<T> result) {
    ref.invalidate(mySpecialDaysProvider);
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return null;
      },
      failure: (Failure failure) {
        debugPrint('special day action failed: $failure');
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
    );
  }
}
