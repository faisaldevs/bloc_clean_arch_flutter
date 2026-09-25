import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/subject.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/weekly_progress.dart';
import 'package:equatable/equatable.dart';

class SubjectProgress extends Equatable {
  const SubjectProgress({
    required this.weeklyProgress,
    required this.subjects,
  });

  final WeeklyProgress weeklyProgress;
  final List<Subject> subjects;

  @override
  List<Object?> get props => [weeklyProgress, subjects];
}