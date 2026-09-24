part of 'login_bloc.dart';

/// Things the UI tells the bloc happened. Past tense: an event reports,
/// it does not command.
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// The user tapped "Log In" with these values in the form.
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.mobile, required this.password});

  final String mobile;
  final String password;

  @override
  List<Object?> get props => [mobile, password];
}
