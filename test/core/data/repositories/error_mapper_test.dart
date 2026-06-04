import 'package:derpiviewer/core/data/error_mapper.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioError _dioError({
  required String path,
  required DioErrorType type,
  int? statusCode,
}) {
  return DioError(
    requestOptions: RequestOptions(path: path),
    type: type,
    response: statusCode != null
        ? Response(
            statusCode: statusCode,
            requestOptions: RequestOptions(path: path),
          )
        : null,
    error: 'Test error for $path',
  );
}

void main() {
  group('mapDioError', () {
    test('connectTimeout maps to FailureType.network', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.connectTimeout,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.network);
      expect(failure.message, contains('Network error'));
    });

    test('DioErrorType.other maps to FailureType.network', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.other,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.network);
      expect(failure.message, contains('Network error'));
    });

    test('receiveTimeout maps to FailureType.timeout', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.receiveTimeout,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.timeout);
      expect(failure.message, 'Request timed out');
    });

    test('sendTimeout maps to FailureType.timeout', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.sendTimeout,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.timeout);
    });

    test('404 response maps to FailureType.notFound', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.response,
        statusCode: 404,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.notFound);
      expect(failure.message, contains('404'));
    });

    test('403 response maps to FailureType.api', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.response,
        statusCode: 403,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.api);
      expect(failure.message, contains('403'));
    });

    test('401 response maps to FailureType.api', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.response,
        statusCode: 401,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.api);
      expect(failure.message, contains('401'));
    });

    test('500 response maps to FailureType.api', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.response,
        statusCode: 500,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.api);
    });

    test('cancel maps to FailureType.network', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.cancel,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.network);
      expect(failure.message, 'Request cancelled');
    });

    test('unexpected HTTP status maps to FailureType.api', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.response,
        statusCode: 418,
      );
      final failure = mapDioError(error);
      expect(failure.type, FailureType.api);
    });

    test('all mapped results have correct FailureTypes', () {
      final testCases = {
        _dioError(path: '/a', type: DioErrorType.connectTimeout): FailureType.network,
        _dioError(path: '/b', type: DioErrorType.receiveTimeout): FailureType.timeout,
        _dioError(path: '/c', type: DioErrorType.sendTimeout): FailureType.timeout,
        _dioError(path: '/d', type: DioErrorType.other): FailureType.network,
        _dioError(path: '/e', type: DioErrorType.cancel): FailureType.network,
        _dioError(path: '/f', type: DioErrorType.response, statusCode: 404): FailureType.notFound,
        _dioError(path: '/g', type: DioErrorType.response, statusCode: 403): FailureType.api,
        _dioError(path: '/h', type: DioErrorType.response, statusCode: 401): FailureType.api,
      };
      for (final entry in testCases.entries) {
        final failure = mapDioError(entry.key);
        expect(failure.type, entry.value,
            reason: 'Expected ${entry.key.type} → ${entry.value}');
      }
    });

    test('error and stackTrace propagate from DioError to Failure', () {
      final error = _dioError(
        path: '/test',
        type: DioErrorType.connectTimeout,
      );
      final failure = mapDioError(error);
      expect(failure.error, isNotNull);
      expect(failure.error, isA<DioError>());
    });
  });
}
