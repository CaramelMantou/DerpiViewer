import 'package:flutter_test/flutter_test.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';

void main() {
  testWidgets('App smoke test — providers wired', (WidgetTester tester) async {
    // Verify that core domain types are importable and usable
    expect(const LoadingState<Object>(), isA<ViewState<Object>>());
    expect(const SuccessState<String>('data').data, 'data');
    expect(const FailureState<String>('err', FailureType.network).message, 'err');
    expect(const FailureState<String>('err', FailureType.network).type, FailureType.network);
    expect(const Success<int>(42).data, 42);
    expect(const Failure<int>('fail', FailureType.api).message, 'fail');
  });
}
