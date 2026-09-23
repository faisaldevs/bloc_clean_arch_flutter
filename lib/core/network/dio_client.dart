
import 'package:bloc_clean_arch_flutter/core/network/api_endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_interceptor.dart';

abstract final class DioClient {
  /// get_it instance name for the interceptor-free Dio.
  static const plainDioName = 'plainDio';

  static BaseOptions _baseOptions() => BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      );

  /// Used by every API service. Attaches tokens and handles refresh.
  static Dio createMain({required AuthInterceptor authInterceptor}) {
    final dio = Dio(_baseOptions());
    // Order matters: auth first, so the log shows the real outgoing headers.
    dio.interceptors.add(authInterceptor);
    if (kDebugMode) dio.interceptors.add(_logger());
    return dio;
  }

  /// No AuthInterceptor. Used only for the refresh call and the retry,
  /// so a failing refresh can never loop or deadlock.
  static Dio createPlain() {
    final dio = Dio(_baseOptions());
    if (kDebugMode) dio.interceptors.add(_logger());
    return dio;
  }

  // Debug only: this prints headers and bodies, including tokens.
  static LogInterceptor _logger() => LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      );
}