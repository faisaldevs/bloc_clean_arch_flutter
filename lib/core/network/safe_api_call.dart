import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:dio/dio.dart';

/// Runs a Retrofit/Dio call and converts whatever it throws into this
/// app's own exceptions, so no data source — and nothing above it — ever
/// needs to import Dio or know it exists.
Future<T> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw _mapDioException(e);
  } on TypeError {
    throw const ServerException(message: 'Unexpected response format');
  } on FormatException {
    throw const ServerException(message: 'Unexpected response format');
  }
}

Exception _mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.cancel:
      return const ServerException(message: 'Request cancelled');
    default:
      // `EnvelopeInterceptor` rejects before unwrapping, so this is still
      // the full { code, message, data } envelope when present.
      final body = e.response?.data;
      final message = (body is Map && body['message'] is String)
          ? body['message'] as String
          : 'Something went wrong';
      final code =
          (body is Map ? body['code'] as int? : null) ?? e.response?.statusCode;
      return ServerException(message: message, statusCode: code);
  }
}
