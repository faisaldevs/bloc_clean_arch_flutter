import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a [Stream] (e.g. a bloc's `stream`) to the [Listenable] that
/// `GoRouter.refreshListenable` expects, so the router re-runs its
/// `redirect` every time the stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
