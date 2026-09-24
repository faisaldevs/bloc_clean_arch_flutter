import 'package:dio/dio.dart';

/// Every endpoint wraps its payload in `{ code, message, data }`, and the
/// API always answers HTTP 200 — the real result is this `code`, not the
/// HTTP status line. This interceptor turns that convention into normal
/// Dio semantics, in one place, so no data source has to know about it:
/// a non-200 `code` becomes a rejected [DioException] (so `on
/// DioException` catches it everywhere, same as a real HTTP error), and a
/// 200 `code` gets its `data` unwrapped so callers never see the envelope.
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('code')) {
      final code = body['code'] as int?;
      if (code != 200) {
        // `true`: let interceptors added before this one (e.g. the token
        // refresh interceptor) still see this as an error.
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            message: body['message'] as String?,
          ),
          true,
        );
        return;
      }
      response.data = body['data']; // Map, List or null all work.
    }
    handler.next(response);
  }
}
