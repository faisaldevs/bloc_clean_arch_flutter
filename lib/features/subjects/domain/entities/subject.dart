import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  const Subject({
    required this.id,
    this.image,
    required this.name,
    required this.totalQuestions,
    required this.practicedQuestions,
    required this.remainingQuestions,
    required this.completionPercent,
    required this.accuracyPercent,
    required this.correctCount,
    required this.wrongCount,
    required this.skipCount,
    required this.answeredCount,
    required this.isStarted,
  });

  final int id;
  final String? image;
  final String name;
  final int totalQuestions;
  final int practicedQuestions;
  final int remainingQuestions;
  final double completionPercent;
  final double accuracyPercent;
  final int correctCount;
  final int wrongCount;
  final int skipCount;
  final int answeredCount;
  final bool isStarted;

  @override
  List<Object?> get props => [
    id,
    image,
    name,
    totalQuestions,
    practicedQuestions,
    remainingQuestions,
    completionPercent,
    accuracyPercent,
    correctCount,
    wrongCount,
    skipCount,
    answeredCount,
    isStarted,
  ];
}


