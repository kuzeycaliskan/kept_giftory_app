import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/router/follow_route.dart';

void main() {
  test('tab roots are told apart from detail routes', () {
    expect(isShellRoot('/'), isTrue);
    expect(isShellRoot('/gifts'), isTrue);
    expect(isShellRoot('/me'), isTrue);
    // Query strings do not change where a route lands.
    expect(isShellRoot('/gifts?tab=ideas'), isTrue);
    expect(isShellRoot('/gifts/g1?side=giver'), isFalse);
    expect(isShellRoot('/events/e1'), isFalse);
    expect(isShellRoot('/users/u1?name=Ali'), isFalse);
  });
}
