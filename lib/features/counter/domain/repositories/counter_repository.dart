import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';
import 'package:fpdart/fpdart.dart';

/// What the domain needs from storage, with no hint of how it is stored.
///
/// Declared here but implemented in the data layer, so domain depends on
/// an abstraction it owns rather than on a concrete database.
abstract class CounterRepository {
  Future<Either<Failure, Counter>> getCounter();

  Future<Either<Failure, Counter>> saveCounter(Counter counter);
}
