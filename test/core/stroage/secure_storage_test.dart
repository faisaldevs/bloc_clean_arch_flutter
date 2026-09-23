// import 'package:bloc_clean_arch_flutter/core/stroage/secure_storage.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// class MockSecureStorage extends Mock implements FlutterSecureStorage {}

// void main() {
//   // const accessTokenKey = "acess_token_key";
//   // const refreshTokenKey = "refresh_token_key";

//   MockSecureStorage mockSecureStorage;
//   SecureStorage secureStorage;

//   setUp(() {
//     mockSecureStorage = MockSecureStorage();
//     secureStorage = SecureStorage(mockSecureStorage);
//   });

// }

import 'package:bloc_clean_arch_flutter/core/error/exceptions.dart';
import 'package:bloc_clean_arch_flutter/core/stroage/secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  const accessTokenKey = "acess_token_key";
  const refreshTokenKey = "refresh_token_key";

  late MockSecureStorage mockSecureStorage;
  late SecureStorage secureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    secureStorage = SecureStorage(mockSecureStorage);
  });

  group("Save Tokens", () {
    test("Write Both Tokens Under Correct Key", () async {
      // Arrange
      when(
        () => mockSecureStorage.write(
          key: any(named: "key"),
          value: any(named: "value"),
        ),
      ).thenAnswer((invocation) async {});

      //  Act
      await secureStorage.saveTokens(accessToken: "acc", refreshToken: "ref");

      //  Assert
      verify(
        () => mockSecureStorage.write(key: accessTokenKey, value: "acc"),
      ).called(1);
      verify(
        () => mockSecureStorage.write(key: refreshTokenKey, value: "ref"),
      ).called(1);
    });

    test('throws CacheException when the plugin fails', () async {
      //Arrange

      when(
        () => mockSecureStorage.write(
          key: any(named: "key"),
          value: any(named: "value"),
        ),
      ).thenThrow(PlatformException(code: "error"));

      // Act & Assert
      await expectLater(
        () => secureStorage.saveTokens(accessToken: "acc", refreshToken: "ref"),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getAccessToken', () {
    test('returns the stored token', () async {
      when(
        () => mockSecureStorage.read(key: accessTokenKey),
      ).thenAnswer((_) async => 'acc');

      expect(await secureStorage.getAccessToken(), 'acc');
    });

    test('returns null when no token is stored', () async {
      when(
        () => mockSecureStorage.read(key: accessTokenKey),
      ).thenAnswer((_) async => null);

      expect(await secureStorage.getAccessToken(), isNull);
    });

    test('throws CacheException when the plugin fails', () async {
      when(
        () => mockSecureStorage.read(key: accessTokenKey),
      ).thenThrow(PlatformException(code: 'error'));

      await expectLater(
        () => secureStorage.getAccessToken(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getRefreshToken', () {
    test('returns the stored token', () async {
      when(
        () => mockSecureStorage.read(key: refreshTokenKey),
      ).thenAnswer((_) async => 'acc');

      expect(await secureStorage.getRefreshToken(), 'acc');
    });

    test('returns null when no token is stored', () async {
      when(
        () => mockSecureStorage.read(key: refreshTokenKey),
      ).thenAnswer((_) async => null);

      expect(await secureStorage.getRefreshToken(), isNull);
    });

    test('throws CacheException when the plugin fails', () async {
      when(
        () => mockSecureStorage.read(key: refreshTokenKey),
      ).thenThrow(PlatformException(code: 'error'));

      await expectLater(
        () => secureStorage.getRefreshToken(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('clear', () {
    test('deletes only the two token keys', () async {
      when(
        () => mockSecureStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await secureStorage.clear();

      verify(() => mockSecureStorage.delete(key: accessTokenKey)).called(1);
      verify(() => mockSecureStorage.delete(key: refreshTokenKey)).called(1);
      verifyNever(() => mockSecureStorage.deleteAll());
    });
  });
}
