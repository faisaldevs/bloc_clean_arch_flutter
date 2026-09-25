import 'package:bloc_clean_arch_flutter/core/network/auth_interceptor.dart';
import 'package:bloc_clean_arch_flutter/core/network/dio_client.dart';
import 'package:bloc_clean_arch_flutter/core/network/session_expired_notifier.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/secure_storage.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/datasources/auth_api_service.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/repositories/auth_repository_impl.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/repositories/auth_repository.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/get_current_user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/login.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/logout.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/watch_auth_state.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/auth_bloc.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/login_bloc.dart';
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
  _initStorage();
  _initAuth();
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

void _initAuth() {
  // Blocs — factories. `LoginBloc` is per login screen; `AuthBloc` is
  // created once by the app root, which owns and closes it.
  sl.registerFactory(() => LoginBloc(login: sl()));
  sl.registerFactory(
    () => AuthBloc(getCurrentUser: sl(), watchAuthState: sl(), logout: sl()),
  );

  // Use cases.
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => WatchAuthState(sl()));

  // Repository — registered under the domain interface. Must be a
  // singleton: it owns the auth-state stream every listener shares.
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      sessionExpiredNotifier: sl(),
    ),
  );

  // Data source — uses the main Dio (token-attaching, refreshing one),
  // not the plain Dio reserved for the refresh call itself.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton(() => AuthApiService(sl<Dio>()));
}
