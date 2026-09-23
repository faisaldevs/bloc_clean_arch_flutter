import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/repositories/counter_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Loads the current counter, used when the screen first opens.
class GetCounter implements UseCase<Counter, NoParams> {
  const GetCounter(this.repository);

  final CounterRepository repository;

  @override
  Future<Either<Failure, Counter>> call(NoParams params) {
    return repository.getCounter();
  }
}
