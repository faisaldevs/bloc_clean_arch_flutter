import 'package:bloc_clean_arch_flutter/core/bloc/app_bloc_observer.dart';
import 'package:bloc_clean_arch_flutter/core/router/routes.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/auth_bloc.dart';
import 'package:bloc_clean_arch_flutter/injection_container.dart' as di;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  // Required because `di.init` runs before `runApp` and may await plugins.
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) Bloc.observer = const AppBlocObserver();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Stateful so the [AuthBloc] and the router are created exactly once and
/// survive rebuilds — the router listens to this bloc for its redirects.
class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc = di.sl<AuthBloc>()
    ..add(const AuthSubscriptionRequested());
  late final GoRouter _router = AppRouter.create(_authBloc);

  @override
  void dispose() {
    _router.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `.value`: this state owns the bloc and closes it in `dispose`.
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'BLoC Clean Architecture',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      ),
    );
  }
}
