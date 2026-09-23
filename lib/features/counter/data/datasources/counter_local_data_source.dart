import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/features/counter/data/models/counter_model.dart';

/// Local persistence contract for the counter.
///
/// Throws [CacheException] on failure. Returning failures is the
/// repository's job, not this layer's.
abstract class CounterLocalDataSource {
  Future<CounterModel> getCounter();

  Future<CounterModel> cacheCounter(CounterModel counter);
}

/// Keeps the counter in memory for the lifetime of the process.
///
/// Swapping in SharedPreferences, Hive or a database means replacing this
/// class only; nothing above the data layer changes.
class InMemoryCounterLocalDataSource implements CounterLocalDataSource {
  CounterModel? _cached;

  @override
  Future<CounterModel> getCounter() async {
    return _cached ??= const CounterModel(value: 0);
  }

  @override
  Future<CounterModel> cacheCounter(CounterModel counter) async {
    _cached = counter;
    return counter;
  }
}
