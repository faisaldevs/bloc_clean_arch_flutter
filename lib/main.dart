import 'package:bloc_clean_arch_flutter/core/router/routes.dart';
import 'package:bloc_clean_arch_flutter/injection_container.dart' as di;
import 'package:flutter/material.dart';

Future<void> main() async {
  // Required because `di.init` runs before `runApp` and may await plugins.
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const CounterPage(),
    );
  }
}
