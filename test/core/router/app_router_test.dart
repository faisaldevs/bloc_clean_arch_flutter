import 'package:bloc_clean_arch_flutter/core/router/routes.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const splash = AppRouteName.splash;
  const login = AppRouteName.login;
  const home = AppRouteName.home;

  String? redirect(AuthStatus status, String location) =>
      AppRouter.redirectFor(status, location);

  test('holds every route on splash while the status is unknown', () {
    expect(redirect(AuthStatus.unknown, splash), isNull);
    expect(redirect(AuthStatus.unknown, home), splash);
    expect(redirect(AuthStatus.unknown, login), splash);
  });

  test('sends unauthenticated users to login', () {
    expect(redirect(AuthStatus.unauthenticated, splash), login);
    expect(redirect(AuthStatus.unauthenticated, home), login);
    expect(redirect(AuthStatus.unauthenticated, login), isNull);
  });

  test('sends authenticated users off splash and login to home', () {
    expect(redirect(AuthStatus.authenticated, splash), home);
    expect(redirect(AuthStatus.authenticated, login), home);
    expect(redirect(AuthStatus.authenticated, home), isNull);
  });
}
