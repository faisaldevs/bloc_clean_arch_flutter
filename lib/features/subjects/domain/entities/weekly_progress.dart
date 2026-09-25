import 'package:equatable/equatable.dart';

class WeeklyProgress extends Equatable {
  const WeeklyProgress({
    required this.questionsPracticed,
    required this.previousWeek,
    required this.trend,
    required this.changePersent,
  });

  final int questionsPracticed;
  final int previousWeek;
  final String trend;
  final double changePersent;

  @override
  List<Object?> get props => [
    questionsPracticed,
    previousWeek,
    trend,
    changePersent,
  ];
}
