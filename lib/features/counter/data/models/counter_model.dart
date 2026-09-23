import 'package:bloc_clean_arch_flutter/features/counter/domain/entities/counter.dart';

/// Storage-shaped version of [Counter].
///
/// Extends the entity so it can be returned anywhere a [Counter] is
/// expected, while keeping serialization out of the domain layer.
class CounterModel extends Counter {
  const CounterModel({required super.value});

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  factory CounterModel.fromEntity(Counter counter) {
    return CounterModel(value: counter.value);
  }

  Map<String, dynamic> toJson() => {'value': value};
}
