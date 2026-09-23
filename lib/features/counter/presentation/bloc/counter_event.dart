part of 'counter_bloc.dart';

/// Things the user (or the screen) did. Past tense on purpose: an event
/// reports what happened, it does not command the bloc what to do.
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// The counter screen was opened and needs its initial value.
class CounterStarted extends CounterEvent {
  const CounterStarted();
}

class CounterIncrementPressed extends CounterEvent {
  const CounterIncrementPressed();
}

class CounterDecrementPressed extends CounterEvent {
  const CounterDecrementPressed();
}

class CounterResetPressed extends CounterEvent {
  const CounterResetPressed();
}
