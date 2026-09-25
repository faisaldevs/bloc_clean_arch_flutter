// import 'package:equatable/equatable.dart';

// /// Base type for anything that can go wrong, expressed as a value rather
// /// than a thrown exception so callers are forced to handle it.
// abstract class Failure extends Equatable {
//   const Failure([this.properties = const <dynamic>[]]);

//   final List<dynamic> properties;

//   @override
//   List<Object?> get props => properties;
// }

// /// A local storage read or write did not succeed.
// class CacheFailure extends Failure {
//   const CacheFailure([this.message = 'Could not reach local storage']);

//   final String message;

//   @override
//   List<Object?> get props => [message];
// }

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "No internet connection"]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'Wrong username or password',
  ]);
}

/// No valid session: never logged in, logged out, or the session expired.
final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message = 'Not logged in']);
}

final class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message);
}
