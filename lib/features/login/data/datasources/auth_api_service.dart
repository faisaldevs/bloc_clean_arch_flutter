import 'package:bloc_clean_arch_flutter/core/network/api_endpoint.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_tokens_model.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

part 'auth_api_service.g.dart';

/// EnvelopeInterceptor has already unwrapped { code, message, data } down
/// to `data` and turned a non-200 `code` into a DioException by the time
/// these calls resolve, so Retrofit deserializes straight into the model
/// via each one's `fromJson`.
@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiEndpoints.login)
  Future<AuthTokensModel> login(@Body() LoginRequestModel request);

  @GET(ApiEndpoints.profile)
  Future<UserModel> getProfile();
}
