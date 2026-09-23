class ServerException implements Exception {
  const ServerException({
    this.message = "Unexpected server error",
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message = "No internet connection"});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache operation failed'});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}
