import 'package:dio/dio.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/result.dart';

/// Maps a Dio error to a domain [Failure].
///
/// Exhaustively switches on [DioErrorType] and HTTP status codes
/// to produce the correct [FailureType] for each error category.
Failure mapDioError(DioError error) {
  final type = error.type;

  // Network-level errors
  if (type == DioErrorType.connectTimeout ||
      type == DioErrorType.other) {
    return Failure(
      'Network error: ${error.message}',
      FailureType.network,
      error: error,
      stackTrace: error.stackTrace,
    );
  }

  // Timeout
  if (type == DioErrorType.receiveTimeout ||
      type == DioErrorType.sendTimeout) {
    return Failure(
      'Request timed out',
      FailureType.timeout,
      error: error,
      stackTrace: error.stackTrace,
    );
  }

  // HTTP response errors
  if (type == DioErrorType.response) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 404) {
      return Failure(
        'Not found (404)',
        FailureType.notFound,
        error: error,
        stackTrace: error.stackTrace,
      );
    }

    if (statusCode == 403 || statusCode == 401) {
      final message = statusCode == 403
          ? 'API key invalid or expired'
          : 'Authentication required ($statusCode)';
      return Failure(
        message,
        FailureType.api,
        error: error,
        stackTrace: error.stackTrace,
      );
    }

    // Other HTTP errors
    return Failure(
      'API error ($statusCode): ${error.message}',
      FailureType.api,
      error: error,
      stackTrace: error.stackTrace,
    );
  }

  // Cancelled requests
  if (type == DioErrorType.cancel) {
    return Failure(
      'Request cancelled',
      FailureType.network,
      error: error,
      stackTrace: error.stackTrace,
    );
  }

  // Fallback for unhandled error types
  return Failure(
    'Unexpected error: ${error.message}',
    FailureType.unknown,
    error: error,
    stackTrace: error.stackTrace,
  );
}
