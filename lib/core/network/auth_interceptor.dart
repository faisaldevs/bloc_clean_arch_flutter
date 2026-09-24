// lib/core/network/auth_interceptor.dart
import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/network/api_endpoint.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:dio/dio.dart';

import 'session_expired_notifier.dart';

/// Attaches the access token to every request and refreshes it on 401.
///
/// Rule: every code path calls exactly one of handler.next,
/// handler.resolve or handler.reject. A missed call blocks the queue
/// and freezes every later request in the app.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({
    required this._tokenStorage,
    required this._plainDio,
    required this._sessionExpiredNotifier,
  });

  final BaseSecureStorage _tokenStorage;
  final Dio _plainDio;
  final SessionExpiredNotifier _sessionExpiredNotifier;

  static const _authHeader = 'Authorization';

  // ---------------------------------------------------------------- request

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthEndpoint(options)) {
      try {
        final token = await _tokenStorage.getAccessToken();
        if (token != null) options.headers[_authHeader] = 'Bearer $token';
      } on CacheException {
        // Storage failed: send without a token. The server answers 401
        // and the normal error flow takes over.
      }
    }
    handler.next(options);
  }

  // ------------------------------------------------------------------ error

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    // A 401 on login means wrong credentials, not an expired session.
    if (!_isUnauthorized(err) || _isAuthEndpoint(options)) {
      return handler.next(err);
    }

    // Step 1: get a valid token (refreshing only if nobody else did).
    String? newAccessToken;
    try {
      newAccessToken = await _getValidAccessToken(options);
    } catch (_) {
      newAccessToken = null; // refresh request failed or storage broke
    }

    if (newAccessToken == null) {
      await _expireSession();
      return handler.next(err); // caller still gets its 401
    }

    // Step 2: retry the original request with the new token.
    try {
      final response = await _retry(options, newAccessToken);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.reject(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  // ---------------------------------------------------------------- helpers

  bool _isAuthEndpoint(RequestOptions options) {
    final path = options.uri.path;
    return path.endsWith(ApiEndpoints.login) ||
        path.endsWith(ApiEndpoints.refresh);
  }

  /// This API answers every request with HTTP 200 and puts the real
  /// result in the body's `code` — confirmed for login's 422 case. Token
  /// expiry may or may not follow the same convention, so this checks
  /// both: a real 401 (standard middleware-level auth failure) or a
  /// wrapped `code: 401` (this API's own envelope).
  bool _isUnauthorized(DioException err) {
    if (err.response?.statusCode == 401) return true;
    final body = err.response?.data;
    return body is Map && body['code'] == 401;
  }

  /// Returns a token to retry with, or null if the session is gone.
  Future<String?> _getValidAccessToken(RequestOptions failed) async {
    final sentToken = _bearerFrom(failed);
    final storedToken = await _tokenStorage.getAccessToken();

    // Another queued request already refreshed while this one waited.
    // This is what stops three parallel 401s from refreshing three times.
    if (storedToken != null && storedToken != sentToken) {
      return storedToken;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await _plainDio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );

    // EnvelopeInterceptor already unwrapped { code, message, data } down
    // to just `data`, and would have thrown if the refresh itself failed.
    final data = response.data;
    final accessToken = data?['access_token'] as String?;
    if (accessToken == null) return null;

    // Some backends rotate the refresh token, some don't. Keep the old
    // one if the response doesn't include a new one.
    final newRefreshToken = data?['refresh_token'] as String? ?? refreshToken;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );
    return accessToken;
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    final headers = Map<String, dynamic>.of(options.headers)
      ..[_authHeader] = 'Bearer $token';
    return _plainDio.fetch<dynamic>(options.copyWith(headers: headers));
  }

  String? _bearerFrom(RequestOptions options) {
    final value = options.headers[_authHeader];
    if (value is! String || !value.startsWith('Bearer ')) return null;
    return value.substring('Bearer '.length);
  }

  Future<void> _expireSession() async {
    try {
      await _tokenStorage.clear();
    } on CacheException {
      // Nothing more we can do; still tell the app to log out.
    }
    _sessionExpiredNotifier.notify();
  }
}
