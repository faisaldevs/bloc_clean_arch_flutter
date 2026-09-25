import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/network/session_expired_notifier.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/datasources/auth_remote_data_source.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/models/auth_tokens_model.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/models/user_model.dart';
import 'package:bloc_clean_arch_flutter/features/login/data/repositories/auth_repository_impl.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements BaseSecureStorage {}

void main() {
  const tokens = AuthTokensModel(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresIn: 3600,
  );
  const userModel = UserModel(id: 1, name: 'Test', mobile: '01700000000');
  final user = userModel.toEntity();

  late MockRemote remote;
  late MockTokenStorage storage;
  late SessionExpiredNotifier notifier;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockRemote();
    storage = MockTokenStorage();
    notifier = SessionExpiredNotifier();
    repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: storage,
      sessionExpiredNotifier: notifier,
    );

    when(
      () => storage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await repository.dispose();
    await notifier.dispose();
  });

  void stubLogin() => when(
    () => remote.login(
      mobile: any(named: 'mobile'),
      password: any(named: 'password'),
    ),
  ).thenAnswer((_) async => tokens);

  group('login', () {
    test('saves tokens, returns the user and announces it', () async {
      stubLogin();
      when(() => remote.getProfile()).thenAnswer((_) async => userModel);

      expectLater(repository.authStateChanges, emits(user));
      final result = await repository.login(mobile: 'm', password: 'p');

      expect(result, Right<Failure, User>(user));
      verify(
        () =>
            storage.saveTokens(accessToken: 'access', refreshToken: 'refresh'),
      ).called(1);
    });

    test('maps a 422 to InvalidCredentialsFailure', () async {
      when(
        () => remote.login(
          mobile: any(named: 'mobile'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ServerException(message: 'Wrong', statusCode: 422));

      final result = await repository.login(mobile: 'm', password: 'p');

      expect(
        result,
        const Left<Failure, User>(InvalidCredentialsFailure('Wrong')),
      );
      verifyNever(
        () => storage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });

    test('maps a network error to NetworkFailure', () async {
      when(
        () => remote.login(
          mobile: any(named: 'mobile'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkException());

      final result = await repository.login(mobile: 'm', password: 'p');

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });

    test('clears saved tokens when the profile fetch fails', () async {
      stubLogin();
      when(
        () => remote.getProfile(),
      ).thenThrow(const ServerException(statusCode: 500));

      final result = await repository.login(mobile: 'm', password: 'p');

      expect(result.getLeft().toNullable(), isA<ServerFailure>());
      verify(() => storage.clear()).called(1);
    });
  });

  group('getCurrentUser', () {
    test('returns UnauthenticatedFailure without a network call when no '
        'token is stored', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result.getLeft().toNullable(), isA<UnauthenticatedFailure>());
      verifyZeroInteractions(remote);
    });

    test('returns the user when a token is stored', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'access');
      when(() => remote.getProfile()).thenAnswer((_) async => userModel);

      final result = await repository.getCurrentUser();

      expect(result, Right<Failure, User>(user));
    });

    test('treats a 401 as an expired session and clears tokens', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'access');
      when(
        () => remote.getProfile(),
      ).thenThrow(const ServerException(statusCode: 401));

      final result = await repository.getCurrentUser();

      expect(result.getLeft().toNullable(), isA<UnauthenticatedFailure>());
      verify(() => storage.clear()).called(1);
    });
  });

  group('logout', () {
    test('clears tokens and announces the logout', () async {
      expectLater(repository.authStateChanges, emits(null));

      final result = await repository.logout();

      expect(result, const Right<Failure, Unit>(unit));
      verify(() => storage.clear()).called(1);
    });

    test('still announces the logout when storage fails', () async {
      when(() => storage.clear()).thenThrow(const CacheException());
      expectLater(repository.authStateChanges, emits(null));

      final result = await repository.logout();

      expect(result.getLeft().toNullable(), isA<CacheFailure>());
    });
  });

  test('announces a logout when the session expires', () async {
    expectLater(repository.authStateChanges, emits(null));

    notifier.notify();
  });
}
