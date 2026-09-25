import 'package:json_annotation/json_annotation.dart';

part 'base_api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseApiResponse<T> {
  const BaseApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final T? data;

  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$BaseApiResponseFromJson(json, fromJsonT);
}