// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectProgressModel _$SubjectProgressModelFromJson(
  Map<String, dynamic> json,
) => SubjectProgressModel(
  weeklyProgress: WeeklyProgressModel.fromJson(
    json['weekly_progress'] as Map<String, dynamic>,
  ),
  subjects: (json['subjects'] as List<dynamic>)
      .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SubjectProgressModelToJson(
  SubjectProgressModel instance,
) => <String, dynamic>{
  'weekly_progress': instance.weeklyProgress,
  'subjects': instance.subjects,
};

SubjectModel _$SubjectModelFromJson(Map<String, dynamic> json) => SubjectModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  image: json['image'] as String?,
  totalQuestions: (json['total_questions'] as num).toInt(),
  practicedQuestions: (json['practiced_questions'] as num).toInt(),
  remainingQuestions: (json['remaining_questions'] as num).toInt(),
  completionPercent: (json['completion_percent'] as num).toDouble(),
  accuracyPercent: (json['accuracy_percent'] as num).toDouble(),
  correctCount: (json['correct_count'] as num).toInt(),
  wrongCount: (json['wrong_count'] as num).toInt(),
  skipCount: (json['skip_count'] as num).toInt(),
  answeredCount: (json['answered_count'] as num).toInt(),
  isStarted: json['is_started'] as bool,
);

Map<String, dynamic> _$SubjectModelToJson(SubjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'total_questions': instance.totalQuestions,
      'practiced_questions': instance.practicedQuestions,
      'remaining_questions': instance.remainingQuestions,
      'completion_percent': instance.completionPercent,
      'accuracy_percent': instance.accuracyPercent,
      'correct_count': instance.correctCount,
      'wrong_count': instance.wrongCount,
      'skip_count': instance.skipCount,
      'answered_count': instance.answeredCount,
      'is_started': instance.isStarted,
    };

WeeklyProgressModel _$WeeklyProgressModelFromJson(Map<String, dynamic> json) =>
    WeeklyProgressModel(
      questionsPracticed: (json['questions_practiced'] as num).toInt(),
      previousWeek: (json['previous_week'] as num).toInt(),
      changePercent: (json['change_percent'] as num?)?.toDouble(),
      trend: json['trend'] as String,
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
    );

Map<String, dynamic> _$WeeklyProgressModelToJson(
  WeeklyProgressModel instance,
) => <String, dynamic>{
  'questions_practiced': instance.questionsPracticed,
  'previous_week': instance.previousWeek,
  'change_percent': instance.changePercent,
  'trend': instance.trend,
  'week_start': instance.weekStart.toIso8601String(),
  'week_end': instance.weekEnd.toIso8601String(),
};
