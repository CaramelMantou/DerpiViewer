import 'package:flutter_test/flutter_test.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/ui/providers/trending_provider.dart';

void main() {
  group('TrendingProvider', () {
    test('FetchMoreException has correct message and type', () {
      const exception = FetchMoreException('Test error', FailureType.network);

      expect(exception.message, 'Test error');
      expect(exception.type, FailureType.network);
      expect(exception.toString(), contains('FetchMoreException'));
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('network'));
    });

    test('FetchMoreException implements Exception', () {
      const exception = FetchMoreException('error', FailureType.unknown);
      expect(exception, isA<Exception>());
    });
  });

  group('ViewState', () {
    test('LoadingState equality', () {
      const a = LoadingState<Object>();
      const b = LoadingState<Object>();
      expect(a, equals(b));
    });

    test('SuccessState equality', () {
      const a = SuccessState<String>('data');
      const b = SuccessState<String>('data');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('FailureState equality', () {
      const a = FailureState<String>('msg', FailureType.network);
      const b = FailureState<String>('msg', FailureType.network);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
