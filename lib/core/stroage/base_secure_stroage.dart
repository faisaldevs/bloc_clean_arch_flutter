// lib/core/storage/token_storage.dart

/// Stores the auth tokens.
///
/// Missing tokens return null (the user is simply not logged in).
/// A broken storage throws [CacheException].
abstract class BaseSecureStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clear();
}
