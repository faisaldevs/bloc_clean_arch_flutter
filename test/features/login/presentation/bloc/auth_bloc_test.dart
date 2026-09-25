import 'dart:async';

import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/get_current_user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/logout.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/watch_auth_state.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockWatchAuthState extends Mock implements WatchAuthState {}

class MockLogout extends Mock implements Logout {}

void main() {
  const user = User(
    id: 1,
    name: 'Test',
    mobile: '01700000000',
    hasReward: false,
  );

  late MockGetCurrentUser getCurrentUser;
  late MockWatchAuthState watchAuthState;
  late MockLogout logout;
  late StreamController<User?> authChanges;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getCurrentUser = MockGetCurrentUser();
    watchAuthState = MockWatchAuthState();
    logout = MockLogout();
    authChanges = StreamController<User?>.broadcast();
    when(() => watchAuthState()).thenAnswer((_) => authChanges.stream);
    when(() => logout(any())).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => authChanges.close());

  AuthBloc build() => AuthBloc(
    getCurrentUser: getCurrentUser,
    watchAuthState: watchAuthState,
    logout: logout,
  );

  test('starts in unknown', () {
    expect(build().state, const AuthState.unknown());
  });

  blocTest<AuthBloc, AuthState>(
    'restores an existing session on startup',
    setUp: () => when(
      () => getCurrentUser(any()),
    ).thenAnswer((_) async => const Right(user)),
    build: build,
    act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
    expect: () => const [AuthState.authenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'goes to unauthenticated when there is no session',
    setUp: () => when(
      () => getCurrentUser(any()),
    ).thenAnswer((_) async => const Left(UnauthenticatedFailure())),
    build: build,
    act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
    expect: () => const [AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'follows login and session expiry from the repository stream',
    setUp: () => when(
      () => getCurrentUser(any()),
    ).thenAnswer((_) async => const Left(UnauthenticatedFailure())),
    build: build,
    act: (bloc) async {
      bloc.add(const AuthSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      authChanges.add(user); // LoginBloc logged in
      await Future<void>.delayed(Duration.zero);
      authChanges.add(null); // session expired
    },
    expect: () => const [
      AuthState.unauthenticated(),
      AuthState.authenticated(user),
      AuthState.unauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logs out through the usecase',
    build: build,
    seed: () => const AuthState.authenticated(user),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => const [AuthState.unauthenticated()],
    verify: (_) => verify(() => logout(const NoParams())).called(1),
  );
}
