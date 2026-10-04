import 'package:go_router/go_router.dart';

/// Paths of the bottom-tab shell branches (see the `StatefulShellRoute` in
/// `app_router.dart`). Those pages are always in the stack already, so a
/// route pointing at one must switch tabs rather than push a second copy —
/// go_router asserts on the duplicate page key and the app goes red.
const shellRootPaths = {'/', '/gifts', '/me'};

/// True when [route] lands on a tab root rather than a detail screen.
bool isShellRoot(String route) =>
    shellRootPaths.contains(Uri.parse(route).path);

/// Follows a route the server chose (push payloads, inbox rows): tab roots
/// via `go`, everything else pushed on top of what the user is doing.
void followRoute(GoRouter router, String route) {
  if (isShellRoot(route)) {
    router.go(route);
  } else {
    router.push(route);
  }
}
