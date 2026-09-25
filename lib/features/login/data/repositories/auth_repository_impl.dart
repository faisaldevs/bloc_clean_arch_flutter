// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'dart:async';

import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/network/session_expired_notifier.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._tokenStorage,
    required SessionExpiredNotifier sessionExpiredNotifier,
  }) {
    // The interceptor has already cleared the tokens by the time this
    // fires; all that's left is telling the rest of the app.
    _sessionExpiredSubscription = sessionExpiredNotifier.stream.listen(
      (_) => _authStateController.add(null),
    );
  }

  final AuthRemoteDataSource _remoteDataSource;
  final BaseSecureStorage _tokenStorage;

  final _authStateController = StreamController<User?>.broadcast();
  late final StreamSubscription<void> _sessionExpiredSubscription;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<Either<Failure, User>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      // 1. Get tokens.
      final tokens = await _remoteDataSource.login(
        mobile: mobile,
        password: password,
      );

      // 2. Store them so the interceptor can attach them to the next call.
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // 3. Fetch the profile with the fresh token.
      try {
        final user = (await _remoteDataSource.getProfile()).toEntity();
        _authStateController.add(user);
        return Right(user);
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
      // No token means never logged in — skip a request that can only 401.
      if (await _tokenStorage.getAccessToken() == null) {
        return const Left(UnauthenticatedFailure());
      }
      final user = await _remoteDataSource.getProfile();
      return Right(user.toEntity());
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await _clearTokensQuietly();
        return const Left(UnauthenticatedFailure('Session expired'));
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
    } finally {
      // The user asked to leave: sign them out of the UI even if storage
      // failed to clear.
      _authStateController.add(null);
    }
  }

  /// Releases the stream. The app keeps this repository for its whole
  /// lifetime, so in practice only tests call this.
  Future<void> dispose() async {
    await _sessionExpiredSubscription.cancel();
    await _authStateController.close();
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
