part of 'auth_bloc.dart';

enum AuthStatus {
  /// Startup check still running — show a splash, not the login screen.
  unknown,
  authenticated,
  unauthenticated,
}

/// One class with a status rather than a subclass per case: the router
/// only ever asks "which status?", and `user` is non-null exactly when
/// the status is [AuthStatus.authenticated].
final class AuthState extends Equatable {
  const AuthState._({required this.status, this.user});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(User user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final User? user;

  @override
  List<Object?> get props => [status, user];
}
