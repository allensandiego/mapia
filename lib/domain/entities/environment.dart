import 'package:freezed_annotation/freezed_annotation.dart';
import 'variable.dart';

part 'environment.freezed.dart';
part 'environment.g.dart';

@freezed
class Environment with _$Environment {
  const factory Environment({
    required String id,
    required String name,
    @Default([]) List<Variable> variables,
  }) = _Environment;

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);
}
