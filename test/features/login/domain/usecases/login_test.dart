import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/repositories/auth_repository.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = User(
    id: 1,
    name: 'Test',
    mobile: '01700000000',
    hasReward: false,
  );

  late MockAuthRepository repository;
  late Login login;

  setUp(() {
    repository = MockAuthRepository();
    login = Login(repository);
  });

  test('rejects an empty mobile without calling the repository', () async {
    final result = await login(
      const LoginParams(mobile: '   ', password: 'secret123'),
    );

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable(), isA<InvalidInputFailure>());
    verifyZeroInteractions(repository);
  });

  test('rejects a short password without calling the repository', () async {
    final result = await login(
      const LoginParams(mobile: '01700000000', password: '12345'),
    );

    expect(result.getLeft().toNullable(), isA<InvalidInputFailure>());
    verifyZeroInteractions(repository);
  });

  test(
    'trims the mobile and delegates valid input to the repository',
    () async {
      when(
        () => repository.login(
          mobile: any(named: 'mobile'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(user));

      final result = await login(
        const LoginParams(mobile: ' 01700000000 ', password: 'secret123'),
      );

      expect(result, const Right<Failure, User>(user));
      verify(
        () => repository.login(mobile: '01700000000', password: 'secret123'),
      ).called(1);
    },
  );

  test('passes repository failures through unchanged', () async {
    when(
      () => repository.login(
        mobile: any(named: 'mobile'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

    final result = await login(
      const LoginParams(mobile: '01700000000', password: 'secret123'),
    );

    expect(result, const Left<Failure, User>(InvalidCredentialsFailure()));
  });
}
