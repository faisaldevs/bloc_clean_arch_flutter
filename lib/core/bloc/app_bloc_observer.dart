import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs every bloc's transitions and errors in one place, so no bloc needs
/// its own print statements. Installed in debug builds only.
///
/// This is also the single hook to forward errors to a crash reporter
/// later.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    debugPrint(
      '[${bloc.runtimeType}] ${transition.event.runtimeType}: '
      '${transition.currentState.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('[${bloc.runtimeType}] error: $error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
