import 'package:equatable/equatable.dart';

/// The counter as the business understands it.
///
/// Immutable: every rule returns a brand new [Counter] instead of mutating
/// this one, so states can never be accidentally shared or compared wrong.
class Counter extends Equatable {
  const Counter({required this.value});

  /// The value a counter starts at.
  const Counter.initial() : value = 0;

  final int value;

  Counter increment() => Counter(value: value + 1);

  Counter decrement() => Counter(value: value - 1);

  @override
  List<Object?> get props => [value];
}
