part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App started: check for an existing session, then follow auth changes.
/// Added exactly once, when the app root creates the bloc.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// The user tapped "Log out".
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
