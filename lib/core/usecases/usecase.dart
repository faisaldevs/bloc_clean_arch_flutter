import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

/// Contract every use case implements.
///
/// [T] is what the use case produces on success, [Params] is what it needs
/// to run. Defining `call` means a use case is invoked like a function:
/// `await incrementCounter(const NoParams())`.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Placeholder for use cases that take no arguments.
///
/// A dedicated type keeps the [UseCase] signature uniform instead of
/// forcing `void` or nullable params into the generic.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
