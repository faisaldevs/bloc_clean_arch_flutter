import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/login.dart';
import 'package:bloc_clean_arch_flutter/features/login/presentation/bloc/login_bloc.dart';
import 'package:bloc_clean_arch_flutter/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Creates and provides the bloc. Kept separate from [LoginView] so the
/// view can be widget-tested with a mock bloc and no service locator.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    // Instant feedback in the UI; the `Login` usecase still enforces the
    // same rules, so the bloc is safe whatever the UI sends.
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginBloc>().add(
      LoginSubmitted(
        mobile: _mobileController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Mobile',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateMobile,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: validatePassword,
                    onFieldSubmitted: (_) => _submit(context),
                  ),
                  const SizedBox(height: 24),
                  // `listener` handles one-off side effects (snackbars),
                  // `builder` renders the button itself off the same state.
                  // No success branch: on login, AuthBloc's state changes and
                  // the router swaps this page for home.
                  BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginFailure) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is LoginInProgress;
                      return FilledButton(
                        onPressed: isLoading ? null : () => _submit(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Log In'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same rules as the `Login` usecase, applied as the user types.
@visibleForTesting
String? validateMobile(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Enter your mobile number' : null;

@visibleForTesting
String? validatePassword(String? value) =>
    (value == null || value.length < Login.minPasswordLength)
    ? 'Password must be at least ${Login.minPasswordLength} characters'
    : null;
