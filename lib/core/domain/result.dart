import 'package:derpiviewer/core/domain/failure_type.dart';

/// Represents the result of an operation that can either succeed or fail.
///
/// Use [Success] for successful results and [Failure] for errors.
/// This is a Dart 3 sealed class — call sites must handle both variants.
sealed class Result<T> {
  const Result();
}

/// A successful result containing [data].
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      other is Success<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

/// A failed result with error details.
class Failure<T> extends Result<T> {
  final String message;
  final FailureType type;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(
    this.message,
    this.type, {
    this.error,
    this.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      other is Failure<T> &&
      other.message == message &&
      other.type == type;

  @override
  int get hashCode => Object.hash(message, type);
}
