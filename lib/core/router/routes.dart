import 'package:bloc_clean_arch_flutter/core/router/go_router_refresh_stream.dart';
import 'package:bloc_clean_arch_flutter/features/home/presentation/pages/home_page.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/auth_bloc.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/pages/login_page.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/pages/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class AppRouteName {
  static const splash = "/";
  static const login = "/login";
  static const home = "/home";

  static String routeName(String name) {
    return name.replaceFirst("/", "");
  }
}

abstract final class AppRouter {
  /// Builds the app's router. Call once and keep the instance — building a
  /// new router on every rebuild resets navigation.
  ///
  /// Auth decides the screen, not the screens themselves: nothing calls
  /// `go(home)` after a login. [AuthBloc] changes state, the router
  /// re-runs [redirectFor], and the right page appears — the same path
  /// handles login, logout, session expiry and the startup check.
  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRouteName.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) =>
          redirectFor(authBloc.state.status, state.matchedLocation),
      routes: [
        GoRoute(
          // name: AppRouteName.routeName(AppRouteName.splash),
          path: AppRouteName.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          name: AppRouteName.routeName(AppRouteName.login),
          path: AppRouteName.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: AppRouteName.routeName(AppRouteName.home),
          path: AppRouteName.home,
          builder: (context, state) => const HomePage(),
        ),
      ],
    );
  }

  /// Returns where to go instead of [location], or null to stay.
  @visibleForTesting
  static String? redirectFor(AuthStatus status, String location) {
    final target = switch (status) {
      AuthStatus.unknown => AppRouteName.splash,
      AuthStatus.unauthenticated => AppRouteName.login,
      // Once logged in, any page is fine except splash and login.
      AuthStatus.authenticated =>
        location == AppRouteName.splash || location == AppRouteName.login
            ? AppRouteName.home
            : location,
    };
    return target == location ? null : target;
  }
}
