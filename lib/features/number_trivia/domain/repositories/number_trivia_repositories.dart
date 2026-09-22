import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:fpdart/fpdart.dart';

abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
