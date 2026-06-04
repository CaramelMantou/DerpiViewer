import 'package:derpiviewer/core/domain/failure_type.dart';

/// Represents the UI state of an async operation.
///
/// Exposes three states: [LoadingState], [SuccessState], [FailureState].
/// Dart 3 sealed class — exhaustive switch at UI call sites.
sealed class ViewState<T> {
  const ViewState();
}

/// Indicates the operation is in progress.
class LoadingState<T> extends ViewState<T> {
  const LoadingState();

  @override
  bool operator ==(Object other) => other is LoadingState<T>;

  @override
  int get hashCode => 0;
}

/// The operation completed successfully with [data].
class SuccessState<T> extends ViewState<T> {
  final T data;
  const SuccessState(this.data);

  @override
  bool operator ==(Object other) =>
      other is SuccessState<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

/// The operation failed with a [message] and [type] classification.
class FailureState<T> extends ViewState<T> {
  final String message;
  final FailureType type;

  const FailureState(this.message, this.type);

  @override
  bool operator ==(Object other) =>
      other is FailureState<T> &&
      other.message == message &&
      other.type == type;

  @override
  int get hashCode => Object.hash(message, type);
}
