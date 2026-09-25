import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/error/failures.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/data/datasource/api/subject_remote_data_source.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/entities/subject_progress.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  const SubjectRepositoryImpl(this._remoteDataSource);

  final SubjectRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, SubjectProgress>> getSubjectProgress() async {
    try {
      final model = await _remoteDataSource.getSubjectProgress();
      return Right(model.toEntity());

      
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
