// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required BaseSecureStorage tokenStorage,
  })  : _remote = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remote;
  final BaseSecureStorage _tokenStorage;

  @override
  Future<Either<Failure, User>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      // 1. Get tokens.
      final tokens = await _remote.login(mobile: mobile, password: password);

      // 2. Store them so the interceptor can attach them to the next call.
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // 3. Fetch the profile with the fresh token.
      try {
        final user = await _remote.getProfile();
        return Right(user.toEntity());
      } catch (e) {
        // Tokens saved but no profile: never leave that half-state behind.
        await _clearTokensQuietly();
        rethrow;
      }
    } on ServerException catch (e) {
      return Left(_loginFailure(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _remote.getProfile();
      return Right(user.toEntity());
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await _clearTokensQuietly();
        return const Left(InvalidCredentialsFailure('Session expired'));
      }
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _tokenStorage.clear();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  /// 422 is what this API returns for a bad mobile/password pair.
  Failure _loginFailure(ServerException e) => switch (e.statusCode) {
    422 => InvalidCredentialsFailure(e.message),
    400 => InvalidInputFailure(e.message),
    _ => ServerFailure(e.message, statusCode: e.statusCode),
  };

  Future<void> _clearTokensQuietly() async {
    try {
      await _tokenStorage.clear();
    } on CacheException {
      // Already failing; nothing useful to do.
    }
  }
}
