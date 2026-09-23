import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/repositories/counter_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Puts the counter back to its starting value.
///
/// No read first: reset does not depend on the current value.
class ResetCounter implements UseCase<Counter, NoParams> {
  const ResetCounter(this.repository);

  final CounterRepository repository;

  @override
  Future<Either<Failure, Counter>> call(NoParams params) {
    return repository.saveCounter(const Counter.initial());
  }
}
