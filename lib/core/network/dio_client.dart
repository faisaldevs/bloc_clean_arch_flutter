
import 'package:bloc_clean_arch_flutter/core/network/api_endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_interceptor.dart';
import 'envelope_interceptor.dart';

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
    // Order matters. Dio runs onRequest in add-order and onResponse/onError
    // in reverse: auth added first sees the request first going out, and
    // sees the response/error *last* coming back — after the envelope
    // interceptor has already turned a bad `code` into a DioException.
    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(EnvelopeInterceptor());
    if (kDebugMode) dio.interceptors.add(_logger());
    return dio;
  }

  /// No AuthInterceptor. Used only for the refresh call and the retry,
  /// so a failing refresh can never loop or deadlock. Still gets the
  /// envelope interceptor, so a failed refresh throws like everything else.
  static Dio createPlain() {
    final dio = Dio(_baseOptions());
    dio.interceptors.add(EnvelopeInterceptor());
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