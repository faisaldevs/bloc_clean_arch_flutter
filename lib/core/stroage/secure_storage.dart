
import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/base_secure_stroage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage implements BaseSecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = "acess_token_key";
  static const _refreshTokenKey = "refresh_token_key";

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
    } on PlatformException catch (e) {
      throw CacheException(message: 'Could not save tokens: ${e.message}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    // return await _storage.read(key: _accessTokenKey);
    try {
      return await _storage.read(key: _accessTokenKey);
    } on PlatformException catch (e) {
      throw CacheException(
        message: 'Could not read Access Token: ${e.message}',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } on PlatformException catch (e) {
      throw CacheException(
        message: 'Could not read Refresh Token: ${e.message}',
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
    } on PlatformException catch (e) {
      throw CacheException(message: 'Could not clear tokens: ${e.message}');
    }
  }
}
