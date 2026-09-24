import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/usecases/login.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Message shown when a failure has no more specific text.
const _unexpectedFailureMessage = 'Something went wrong. Please try again.';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.login}) : super(const LoginInitial()) {
    // `droppable`: ignores new LoginSubmitted events while one is still
    // running, so double-tapping the button can't fire two logins at once.
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final Login login;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginInProgress());

    final result = await login(
      LoginParams(mobile: event.mobile, password: event.password),
    );

    emit(
      result.fold(
        (failure) => LoginFailure(_messageFor(failure)),
        (user) => LoginSuccess(user),
      ),
    );
  }

  /// Turning a [Failure] into words is a presentation concern, which is
  /// why the domain layer carries no user-facing strings.
  String _messageFor(Failure failure) {
    return switch (failure) {
      InvalidInputFailure(:final message) => message,
      InvalidCredentialsFailure(:final message) => message,
      NetworkFailure(:final message) => message,
      _ => _unexpectedFailureMessage,
    };
  }
}
