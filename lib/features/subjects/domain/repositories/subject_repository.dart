import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/subject_progress.dart';
import 'package:fpdart/fpdart.dart';

abstract class SubjectRepository {
  Future<Either<Failure, SubjectProgress>> getSubjectProgress();
}
