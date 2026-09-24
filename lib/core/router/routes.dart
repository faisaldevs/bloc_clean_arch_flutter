import 'package:bloc_clean_arch_flutter/features/login/presentation/pages/login_page.dart';
import 'package:go_router/go_router.dart';

class AppRouteName {
  static const initial = "/";
  static const login = "/login";

  static String routeName(String name) {
    return name.replaceFirst("/", "");
  }
}

// GoRouter configuration
final router = GoRouter(
  initialLocation: AppRouteName.login,
  routes: [
    GoRoute(
      name: AppRouteName.routeName(AppRouteName.login),
      path: AppRouteName.login,
      builder: (context, state) => LoginPage(),
    ),
  ],
);
