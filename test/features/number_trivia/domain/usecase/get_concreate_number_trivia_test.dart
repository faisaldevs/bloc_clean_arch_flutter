import 'package:bloc_clean_arch_flutter/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:bloc_clean_arch_flutter/features/number_trivia/domain/repositories/number_trivia_repositories.dart';
import 'package:bloc_clean_arch_flutter/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(repository: mockNumberTriviaRepository);
  });

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

  test('should get trivia for the number from the repository', () async {
    // arrange
    when(
      () => mockNumberTriviaRepository.getConcreteNumberTrivia(any()),
    ).thenAnswer((_) async => right(tNumberTrivia));

    // act
    final result = await usecase.execute(number: tNumber);

    // assert
    expect(result, right(tNumberTrivia));
    
    verify(() => mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber))
        .called(1);
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
