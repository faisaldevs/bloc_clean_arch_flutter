import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/login.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/login_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLogin extends Mock implements Login {}

void main() {
  const user = User(
    id: 1,
    name: 'Test',
    mobile: '01700000000',
    hasReward: false,
  );
  const params = LoginParams(mobile: '01700000000', password: 'secret123');

  late MockLogin login;

  setUpAll(() => registerFallbackValue(params));
  setUp(() => login = MockLogin());

  test('starts in LoginInitial', () {
    expect(LoginBloc(login: login).state, const LoginInitial());
  });

  blocTest<LoginBloc, LoginState>(
    'emits [InProgress, Success] when login succeeds',
    setUp: () =>
        when(() => login(any())).thenAnswer((_) async => const Right(user)),
    build: () => LoginBloc(login: login),
    act: (bloc) => bloc.add(
      const LoginSubmitted(mobile: '01700000000', password: 'secret123'),
    ),
    expect: () => const [LoginInProgress(), LoginSuccess(user)],
    verify: (_) => verify(() => login(params)).called(1),
  );

  blocTest<LoginBloc, LoginState>(
    'shows the failure message for known failures',
    setUp: () => when(
      () => login(any()),
    ).thenAnswer((_) async => const Left(InvalidCredentialsFailure('Wrong'))),
    build: () => LoginBloc(login: login),
    act: (bloc) => bloc.add(
      const LoginSubmitted(mobile: '01700000000', password: 'secret123'),
    ),
    expect: () => const [LoginInProgress(), LoginFailure('Wrong')],
  );

  blocTest<LoginBloc, LoginState>(
    'hides raw server messages behind a generic one',
    setUp: () => when(
      () => login(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('SQLSTATE[42S22]'))),
    build: () => LoginBloc(login: login),
    act: (bloc) => bloc.add(
      const LoginSubmitted(mobile: '01700000000', password: 'secret123'),
    ),
    expect: () => const [
      LoginInProgress(),
      LoginFailure('Something went wrong. Please try again.'),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'ignores a second submit while the first is running',
    setUp: () => when(() => login(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return const Right(user);
    }),
    build: () => LoginBloc(login: login),
    act: (bloc) => bloc
      ..add(const LoginSubmitted(mobile: '01700000000', password: 'secret123'))
      ..add(const LoginSubmitted(mobile: '01700000000', password: 'secret123')),
    wait: const Duration(milliseconds: 50),
    expect: () => const [LoginInProgress(), LoginSuccess(user)],
    verify: (_) => verify(() => login(any())).called(1),
  );
}
