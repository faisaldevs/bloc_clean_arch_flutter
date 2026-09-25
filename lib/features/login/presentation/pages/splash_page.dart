import 'package:flutter/material.dart';

/// Shown while [AuthBloc] runs its startup session check. The router
/// moves off this page on its own once the auth status is known.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
