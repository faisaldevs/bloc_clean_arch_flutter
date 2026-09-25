import 'package:bloc_clean_arch_flutter/core/network/api_endpoint.dart';
import 'package:bloc_clean_arch_flutter/features/subjects/data/model/subject_response_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'subject_api_service.g.dart';

@RestApi()
abstract class SubjectApiService {
  factory SubjectApiService(Dio dio, {String? baseUrl}) = _SubjectApiService;

  @GET(ApiEndpoints.subjects)
  Future<SubjectProgressModel> getTasks();

  //   Future<AuthTokensModel> login(@Body() LoginRequestModel request);
}
