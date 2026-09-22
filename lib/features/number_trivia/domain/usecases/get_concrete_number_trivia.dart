import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:bloc_clean_arch_flutter/features/number_trivia/domain/repositories/number_trivia_repositories.dart';
import 'package:fpdart/fpdart.dart';

class GetConcreteNumberTrivia {
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia({required this.repository});

  Future<Either<Failure, NumberTrivia>> execute({required int number}) async {
    return await repository.getConcreteNumberTrivia(number);
  }
}
