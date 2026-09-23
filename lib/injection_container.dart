import 'package:bloc_clean_arch_flutter/core/network/auth_interceptor.dart';
import 'package:bloc_clean_arch_flutter/core/network/dio_client.dart';
import 'package:bloc_clean_arch_flutter/core/network/session_expired_notifier.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/secure_storage.dart';
import 'package:bloc_clean_arch_flutter/features/counter/data/datasources/counter_local_data_source.dart';
import 'package:bloc_clean_arch_flutter/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/repositories/counter_repository.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/decrement_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/get_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/increment_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/domain/usecases/reset_counter.dart';
import 'package:bloc_clean_arch_flutter/features/counter/presentation/bloc/counter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// Service locator. `sl` is the conventional short name for it.
final sl = GetIt.instance;

/// Wires every layer together. Called once from `main` before `runApp`.
///
/// Note the direction: concrete data-layer classes are registered *against*
/// the domain-layer abstractions, so nothing above ever names an
/// implementation.
Future<void> init() async {
  _initCounter();
  _initStorage();
}

void _initCounter() {
  // Bloc — factory, not singleton. Blocs hold state and get closed when the
  // widget is disposed, so each screen needs its own instance.
  sl.registerFactory(
    () => CounterBloc(
      getCounter: sl(),
      incrementCounter: sl(),
      decrementCounter: sl(),
      resetCounter: sl(),
    ),
  );

  // Use cases — stateless, so one shared instance is fine. `lazySingleton`
  // defers construction until first use.
  sl.registerLazySingleton(() => GetCounter(sl()));
  sl.registerLazySingleton(() => IncrementCounter(sl()));
  sl.registerLazySingleton(() => DecrementCounter(sl()));
  sl.registerLazySingleton(() => ResetCounter(sl()));

  // Repository — registered under the domain interface, so callers resolve
  // `CounterRepository` and never learn the implementation's name.
  sl.registerLazySingleton<CounterRepository>(
    () => CounterRepositoryImpl(localDataSource: sl()),
  );

  // Data source — must be a singleton: this instance *is* the storage, so a
  // factory would hand out a fresh, empty counter every time.
  sl.registerLazySingleton<CounterLocalDataSource>(
    InMemoryCounterLocalDataSource.new,
  );
}

void _initStorage() {
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton<BaseSecureStorage>(() => SecureStorage(sl()));

  sl.registerLazySingleton(SessionExpiredNotifier.new);
  sl.registerLazySingleton<Dio>(
    DioClient.createPlain,
    instanceName: DioClient.plainDioName,
  );

  sl.registerLazySingleton(
    () => AuthInterceptor(
      tokenStorage: sl(),
      plainDio: sl(instanceName: DioClient.plainDioName),
      sessionExpiredNotifier: sl(),
    ),
  );

  sl.registerLazySingleton(() => DioClient.createMain(authInterceptor: sl()));
}
