import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/repositories/counter_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Reads the current counter, applies the increment rule, saves the result.
///
/// The rule itself lives on [Counter]; this use case only orchestrates.
class IncrementCounter implements UseCase<Counter, NoParams> {
  const IncrementCounter(this.repository);

  final CounterRepository repository;

  @override
  Future<Either<Failure, Counter>> call(NoParams params) async {
    final current = await repository.getCounter();

    return current.fold<Future<Either<Failure, Counter>>>(
      (failure) async => left<Failure, Counter>(failure),
      (counter) => repository.saveCounter(counter.increment()),
    );
  }
}
