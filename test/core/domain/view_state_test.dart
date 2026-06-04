import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewState<T>', () {
    group('LoadingState', () {
      test('does not carry data', () {
        const state = LoadingState<String>();
        expect(state, isA<ViewState<String>>());
        expect(state, isA<LoadingState<String>>());
        expect(state, isNot(isA<SuccessState<String>>()));
        expect(state, isNot(isA<FailureState<String>>()));
      });

      test('equality works across instances', () {
        const a = LoadingState<int>();
        const b = LoadingState<int>();
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('can be assigned to ViewState variable', () {
        const ViewState<double> state = LoadingState<double>();
        expect(state, isA<LoadingState<double>>());
      });
    });

    group('SuccessState', () {
      test('carries data', () {
        const state = SuccessState<String>('hello');
        expect(state.data, 'hello');
        expect(state, isA<ViewState<String>>());
      });

      test('equality compares by data', () {
        const a = SuccessState<int>(1);
        const b = SuccessState<int>(1);
        const c = SuccessState<int>(2);
        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });

      test('hashCode is based on data', () {
        const a = SuccessState<String>('x');
        const b = SuccessState<String>('x');
        expect(a.hashCode, b.hashCode);
      });

      test('works with complex types', () {
        final list = [1, 2, 3];
        final state = SuccessState<List<int>>(list);
        expect(state.data, list);
        expect(state.data.length, 3);
      });
    });

    group('FailureState', () {
      test('carries message and type', () {
        const state = FailureState<String>('Bad network', FailureType.network);
        expect(state.message, 'Bad network');
        expect(state.type, FailureType.network);
        expect(state, isA<ViewState<String>>());
      });

      test('equality compares by message and type', () {
        const a = FailureState<int>('err', FailureType.timeout);
        const b = FailureState<int>('err', FailureType.timeout);
        const c = FailureState<int>('other', FailureType.timeout);
        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });

      test('hashCode combines message and type', () {
        const a = FailureState<void>('fail', FailureType.api);
        const b = FailureState<void>('fail', FailureType.api);
        expect(a.hashCode, b.hashCode);
      });
    });

    group('exhaustive switch', () {
      String describeState(ViewState<int> state) {
        return switch (state) {
          LoadingState() => 'Loading',
          SuccessState(data: final d) => 'Success: $d',
          FailureState(message: final m, type: final t) => 'Failure[$t]: $m',
        };
      }

      test('covers LoadingState', () {
        expect(describeState(const LoadingState<int>()), 'Loading');
      });

      test('covers SuccessState', () {
        expect(describeState(const SuccessState(7)), 'Success: 7');
      });

      test('covers FailureState', () {
        expect(
          describeState(const FailureState('dead', FailureType.unknown)),
          'Failure[FailureType.unknown]: dead',
        );
      });
    });
  });
}
