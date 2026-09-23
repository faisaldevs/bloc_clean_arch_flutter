import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/decrement_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/get_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/increment_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/reset_counter.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'counter_event.dart';
part 'counter_state.dart';

/// Message shown when a failure has no more specific text.
const _unexpectedFailureMessage = 'Something went wrong. Please try again.';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc({
    required this.getCounter,
    required this.incrementCounter,
    required this.decrementCounter,
    required this.resetCounter,
  }) : super(const CounterInitial()) {
    on<CounterStarted>(_onStarted);

    // The mutating events read the current value before writing a new one,
    // so they must not overlap. `sequential` queues them and keeps two fast
    // taps from both reading the same value and losing one update.
    on<CounterIncrementPressed>(
      _onIncrementPressed,
      transformer: sequential(),
    );
    on<CounterDecrementPressed>(
      _onDecrementPressed,
      transformer: sequential(),
    );
    on<CounterResetPressed>(
      _onResetPressed,
      transformer: sequential(),
    );
  }

  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  final DecrementCounter decrementCounter;
  final ResetCounter resetCounter;

  Future<void> _onStarted(
    CounterStarted event,
    Emitter<CounterState> emit,
  ) {
    return _runUseCase(() => getCounter(const NoParams()), emit);
  }

  Future<void> _onIncrementPressed(
    CounterIncrementPressed event,
    Emitter<CounterState> emit,
  ) {
    return _runUseCase(() => incrementCounter(const NoParams()), emit);
  }

  Future<void> _onDecrementPressed(
    CounterDecrementPressed event,
    Emitter<CounterState> emit,
  ) {
    return _runUseCase(() => decrementCounter(const NoParams()), emit);
  }

  Future<void> _onResetPressed(
    CounterResetPressed event,
    Emitter<CounterState> emit,
  ) {
    return _runUseCase(() => resetCounter(const NoParams()), emit);
  }

  /// Every handler has the same shape, so it lives in one place: announce
  /// work, run the use case, map the result onto a state.
  Future<void> _runUseCase(
    Future<Either<Failure, Counter>> Function() action,
    Emitter<CounterState> emit,
  ) async {
    emit(const CounterLoadInProgress());

    final result = await action();

    emit(
      result.fold(
        (failure) => CounterLoadFailure(_messageFor(failure)),
        (counter) => CounterLoadSuccess(counter),
      ),
    );
  }

  /// Turning a [Failure] into words is a presentation concern, which is why
  /// the domain layer carries no user-facing strings.
  String _messageFor(Failure failure) {
    return switch (failure) {
      CacheFailure(:final message) => message,
      _ => _unexpectedFailureMessage,
    };
  }
}
