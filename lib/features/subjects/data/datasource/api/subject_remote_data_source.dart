import 'package:bloc_clean_arch_flutter/core/network/safe_api_call.dart';

import '../../model/subject_response_model.dart';
import 'subject_api_service.dart';

abstract class SubjectRemoteDataSource {
  Future<SubjectProgressModel> getSubjectProgress();
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  const SubjectRemoteDataSourceImpl(this._api);

  final SubjectApiService _api;

  @override
  Future<SubjectProgressModel> getSubjectProgress() =>
      safeApiCall(_api.getTasks);
}
