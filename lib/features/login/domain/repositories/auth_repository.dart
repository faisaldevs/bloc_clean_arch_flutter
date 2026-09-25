import 'package:fpdart/fpdart.dart';

import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Emits the signed-in [User] after a login, and `null` after a logout or
  /// when the session expires. Only *changes* are emitted — ask
  /// [getCurrentUser] for the state at startup.
  Stream<User?> get authStateChanges;

  Future<Either<Failure, User>> login({
    required String mobile,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, Unit>> logout();
}
