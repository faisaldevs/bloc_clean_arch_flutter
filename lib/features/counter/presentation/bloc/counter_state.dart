part of 'counter_bloc.dart';

/// Everything the counter screen can be showing.
///
/// Equatable matters here: bloc skips emitting a state that equals the
/// current one, which prevents pointless rebuilds.
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object?> get props => [];
}

/// Nothing has been loaded yet.
class CounterInitial extends CounterState {
  const CounterInitial();
}

/// A use case is running.
class CounterLoadInProgress extends CounterState {
  const CounterLoadInProgress();
}

/// A use case finished and produced a counter.
class CounterLoadSuccess extends CounterState {
  const CounterLoadSuccess(this.counter);

  final Counter counter;

  @override
  List<Object?> get props => [counter];
}

/// A use case finished with a failure, already translated for display.
class CounterLoadFailure extends CounterState {
  const CounterLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
