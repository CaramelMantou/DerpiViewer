import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:derpiviewer/core/domain/search_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchInterface extends Mock implements SearchInterface {}

void main() {
  late MockSearchInterface mockModel;

  setUp(() {
    mockModel = MockSearchInterface();
    when(() => mockModel.getBooru()).thenReturn(Booru.derpi);
    when(() => mockModel.getItemID(any<int>())).thenReturn(1);
  });

  group('GalleryToolBar', () {
    testWidgets('renders with icon buttons present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryToolBar(
              model: mockModel,
              index: 0,
              controller: ToolbarController(0),
            ),
          ),
        ),
      );

      // IconButtons include download, share, info
      expect(find.byType(IconButton), findsWidgets);
      // Container widgets include the scrim Container
      expect(find.byType(Container), findsWidgets);
    });
  });
}
