
import 'package:fpdart/fpdart.dart';

import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String mobile,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, Unit>> logout();
}