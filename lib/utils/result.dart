
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
abstract class Result<T, E> with _$Result<T, E> {
  const factory Result.success(T data) = Success;
  const factory Result.error(E data) = Error;
}