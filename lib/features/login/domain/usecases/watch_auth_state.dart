import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/repositories/auth_repository.dart';

/// Streams auth changes: a [User] on login, `null` on logout or session
/// expiry.
///
/// Not a [UseCase]: that contract is a one-shot `Future<Either>`, and this
/// is an ongoing stream with nothing to fail.
class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<User?> call() => _repository.authStateChanges;
}
