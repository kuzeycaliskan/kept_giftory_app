import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/router/app_router.dart';

void main() {
  test('only a change of identity re-runs the redirect rules', () {
    const me = AsyncData<String?>('u1');
    expect(authIdentityChanged(null, me), isTrue);
    expect(authIdentityChanged(me, const AsyncData('u1')), isFalse);
    expect(authIdentityChanged(me, const AsyncData(null)), isTrue);
    // A reload of the same user keeps its value: no tick.
    expect(authIdentityChanged(me, const AsyncLoading<String?>()), isTrue);
  });
}
