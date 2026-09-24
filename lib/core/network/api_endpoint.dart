// lib/core/network/api_endpoints.dart

/// Every URL and path the app calls, defined once.
/// Switching backends means editing this file.
abstract final class ApiEndpoints {
  static const baseUrl = 'https://bcsbooster.com/api';

  static const login = '/auth/v1/login';
  static const refresh = '/auth/v1/refresh';
  static const profile = '/auth/v1/profile';
}
