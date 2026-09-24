part of 'login_bloc.dart';

/// Everything the login screen can be showing.
///
/// Equatable matters: bloc skips emitting a state equal to the current
/// one, so the UI doesn't rebuild for nothing.
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Form is empty, nothing submitted yet.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Login usecase is running.
class LoginInProgress extends LoginState {
  const LoginInProgress();
}

/// Login succeeded — carries the logged-in user.
class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Login failed — message is already presentation-ready text.
class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
