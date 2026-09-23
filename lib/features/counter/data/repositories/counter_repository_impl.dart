import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/counter/data/datasources/counter_local_data_source.dart';
import 'package:bloc_clean_arch_flutter/features/counter/data/models/counter_model.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/repositories/counter_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fulfils the domain's [CounterRepository] contract using local storage.
///
/// This is the boundary where thrown exceptions become returned failures,
/// which is why it is the only place in the feature with a try/catch.
class CounterRepositoryImpl implements CounterRepository {
  const CounterRepositoryImpl({required this.localDataSource});

  final CounterLocalDataSource localDataSource;

  @override
  Future<Either<Failure, Counter>> getCounter() async {
    try {
      final counter = await localDataSource.getCounter();
      return right<Failure, Counter>(counter);
    } on CacheException catch (e) {
      return left<Failure, Counter>(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Counter>> saveCounter(Counter counter) async {
    try {
      final saved = await localDataSource.cacheCounter(
        CounterModel.fromEntity(counter),
      );
      return right<Failure, Counter>(saved);
    } on CacheException catch (e) {
      return left<Failure, Counter>(CacheFailure(e.message));
    }
  }
}
