import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result<T>', () {
    group('Success<T>', () {
      test('wraps value correctly', () {
        const success = Success<int>(42);
        expect(success.data, 42);
      });

      test('works with String type', () {
        const success = Success<String>('hello');
        expect(success.data, 'hello');
      });

      test('works with List type', () {
        final success = Success<List<int>>([1, 2, 3]);
        expect(success.data, [1, 2, 3]);
        expect(success.data.length, 3);
      });

      test('equality compares by data', () {
        const a = Success<int>(42);
        const b = Success<int>(42);
        const c = Success<int>(99);
        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });

      test('hashCode is based on data', () {
        const a = Success<int>(42);
        const b = Success<int>(42);
        expect(a.hashCode, b.hashCode);
      });
    });

    group('Failure<T>', () {
      test('stores message, type, error, stackTrace', () {
        final innerError = Exception('inner');
        final stack = StackTrace.current;
        final failure = Failure<String>(
          'Something went wrong',
          FailureType.network,
          error: innerError,
          stackTrace: stack,
        );
        expect(failure.message, 'Something went wrong');
        expect(failure.type, FailureType.network);
        expect(failure.error, innerError);
        expect(failure.stackTrace, stack);
      });

      test('works without optional fields', () {
        const failure = Failure<int>('Not found', FailureType.notFound);
        expect(failure.message, 'Not found');
        expect(failure.type, FailureType.notFound);
        expect(failure.error, isNull);
        expect(failure.stackTrace, isNull);
      });

      test('equality compares by message and type', () {
        const a = Failure<int>('err', FailureType.network);
        const b = Failure<int>('err', FailureType.network);
        const c = Failure<int>('other', FailureType.network);
        const d = Failure<int>('err', FailureType.api);
        expect(a, equals(b));
        expect(a, isNot(equals(c)));
        expect(a, isNot(equals(d)));
      });

      test('hashCode combines message and type', () {
        const a = Failure<int>('err', FailureType.network);
        const b = Failure<int>('err', FailureType.network);
        expect(a.hashCode, b.hashCode);
      });

      test('all FailureType values are supported', () {
        const types = FailureType.values;
        for (final type in types) {
          final failure = Failure<void>('test $type', type);
          expect(failure.type, type);
        }
      });
    });

    group('exhaustive switch', () {
      // Compile-time verification: these functions must compile without error.
      // If a new Result variant is added, the compiler will flag these.

      String describeResult(Result<int> result) {
        return switch (result) {
          Success(data: final d) => 'Success: $d',
          Failure(message: final m, type: final t) => 'Failure[$t]: $m',
        };
      }

      test('switch covers Success branch', () {
        expect(describeResult(const Success(10)), 'Success: 10');
      });

      test('switch covers Failure branch', () {
        expect(
          describeResult(const Failure('oops', FailureType.api)),
          'Failure[FailureType.api]: oops',
        );
      });
    });
  });
}
