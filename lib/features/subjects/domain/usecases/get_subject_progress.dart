import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/core/usecases/usecase.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/subject_progress.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSubjectProgress implements UseCase<SubjectProgress, NoParams> {
  const GetSubjectProgress(this._repo);

  final SubjectRepository _repo;

  @override
  Future<Either<Failure, SubjectProgress>> call(NoParams params) {
    return _repo.getSubjectProgress();
  }
}
