import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/subject_progress.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/weekly_progress.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/subject.dart';

part 'subject_response_model.g.dart';


@JsonSerializable(fieldRename: FieldRename.snake)
class SubjectProgressModel {
  const SubjectProgressModel({
    required this.weeklyProgress,
    required this.subjects,
  });

  final WeeklyProgressModel weeklyProgress;
  final List<SubjectModel> subjects;

  factory SubjectProgressModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectProgressModelFromJson(json);

  SubjectProgress toEntity() => SubjectProgress(
        weeklyProgress: weeklyProgress.toEntity(),
        subjects: subjects.map((e) => e.toEntity()).toList(),
      );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    this.image,
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
  final String name;
  final String? image;
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

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectModelFromJson(json);

  Subject toEntity() => Subject(
        id: id,
        name: name,
        image: image,
        totalQuestions: totalQuestions,
        practicedQuestions: practicedQuestions,
        remainingQuestions: remainingQuestions,
        completionPercent: completionPercent,
        accuracyPercent: accuracyPercent,
        correctCount: correctCount,
        wrongCount: wrongCount,
        skipCount: skipCount,
        answeredCount: answeredCount,
        isStarted: isStarted,
      );
}


@JsonSerializable(fieldRename: FieldRename.snake)
class WeeklyProgressModel {
  const WeeklyProgressModel({
    required this.questionsPracticed,
    required this.previousWeek,
    this.changePercent,
    required this.trend,
    required this.weekStart,
    required this.weekEnd,
  });

  final int questionsPracticed;
  final int previousWeek;
  final double? changePercent;
  final String trend;
  final DateTime weekStart;
  final DateTime weekEnd;

  factory WeeklyProgressModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyProgressModelFromJson(json);

  WeeklyProgress toEntity() => WeeklyProgress(
        questionsPracticed: questionsPracticed,
        previousWeek: previousWeek,
        changePersent: changePercent ?? 0,
        trend: trend,
      );
}