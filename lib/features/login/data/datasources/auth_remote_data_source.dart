import 'package:bloc_clean_arch_flutter/core/network/safe_api_call.dart';

import '../models/auth_tokens_model.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';
import 'auth_api_service.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String mobile,
    required String password,
  });

  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._api);

  final AuthApiService _api;

  @override
  Future<AuthTokensModel> login({
    required String mobile,
    required String password,
  }) => safeApiCall(
        () => _api.login(LoginRequestModel(mobile: mobile, password: password)),
      );

  @override
  Future<UserModel> getProfile() => safeApiCall(_api.getProfile);
}
