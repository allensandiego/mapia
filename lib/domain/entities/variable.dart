import 'package:freezed_annotation/freezed_annotation.dart';

part 'variable.freezed.dart';
part 'variable.g.dart';

@freezed
class Variable with _$Variable {
  const factory Variable({
    required String key,
    @Default('') String value,
    @Default(true) bool enabled,
    @Default(false) bool isSecret,
    @Default('') String description,
  }) = _Variable;

  factory Variable.fromJson(Map<String, dynamic> json) =>
      _$VariableFromJson(json);
}
