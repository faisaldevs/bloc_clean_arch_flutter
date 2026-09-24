import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/entities/user.dart';
import 'package:bloc_clean_arch_flutter/features/login/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class Login implements UseCase<User, LoginParams> {
  const Login(this._repository);

  final AuthRepository _repository;

  static const minPasswordLength = 6;

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    final mobile = params.mobile.trim();

    if (mobile.isEmpty) {
      return const Left(InvalidInputFailure('Mobile number cannot be empty'));
    }

    if (params.password.length < minPasswordLength) {
      return const Left(
        InvalidInputFailure(
          'Password must be at least $minPasswordLength characters',
        ),
      );
    }

    return _repository.login(mobile: mobile, password: params.password);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.mobile, required this.password});

  final String mobile;
  final String password;

  @override
  List<Object?> get props => [mobile, password];
}
