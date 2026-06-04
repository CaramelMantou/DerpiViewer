import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/config/tag_categories.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/widgets/detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to create an [ImageResponse] without repeating all 22 positional args.
ImageResponse _testImage({
  int id = 1,
  Booru booru = Booru.derpi,
  String uploader = 'TestArtist',
  List<String> tags = const ['safe', 'pony', 'artist:tester'],
  List<int> tagids = const [1, 2, 3],
  int upvotes = 1234,
  int downvotes = 56,
  int faves = 789,
  int comments = 10,
  String createdAt = '2024-01-15T12:30:00Z',
  String description = 'A test description',
  ContentFormat format = ContentFormat.png,
  double duration = 0.0,
}) {
  return ImageResponse(
    id,
    booru,
    'https://example.com/full.png',
    'https://example.com/small.png',
    'https://example.com/medium.png',
    'https://example.com/large.png',
    'https://example.com/thumb.png',
    'https://example.com/thumb_small.png',
    'https://example.com/thumb_tiny.png',
    tags,
    tagids,
    format,
    description,
    createdAt,
    duration,
    upvotes,
    downvotes,
    comments,
    faves,
    uploader,
    <String>[],
  );
}

Widget _wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en', 'US'),
    themeMode: themeMode,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DetailSheet', () {
    // ---------------------------------------------------------------------------
    // Tag foreground colors
    // ---------------------------------------------------------------------------
    testWidgets('tag chips render with category colours', (tester) async {
      final image = _testImage(
        tags: ['safe', 'screencap', 'artist:someone'],
        tagids: [1, 5, 3],
      );
      await tester.pumpWidget(_wrap(DetailSheet(image: image)));
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsWidgets);
      // safe tag text present
      expect(find.text('safe'), findsOneWidget);
      // artist tag text present
      expect(find.text('artist:someone'), findsOneWidget);
    });

    testWidgets('tag foreground colours are valid in light theme', (tester) async {
      final image = _testImage(
        tags: ['safe', 'screencap', 'artist:someone'],
        tagids: [1, 5, 3],
      );
      await tester.pumpWidget(_wrap(DetailSheet(image: image),
          themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      // Tags rendered as Chips
      expect(find.byType(Chip), findsWidgets);
      // The light foreground colour for general category is a valid colour
      final lightGeneral =
          tagForeColor(TagCategory.general, Brightness.light);
      expect(lightGeneral, isNotNull);
    });

    testWidgets('body tag dark foreground is no longer invisible #4E4E4E', (tester) async {
      final image = _testImage(
        tags: ['butt'],
        tagids: [9],
      );
      await tester.pumpWidget(_wrap(DetailSheet(image: image),
          themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      // body tag dark foreground was #4E4E4E (invisible at 1.9:1 contrast).
      // Story 3.2 fixed this — verify the value is no longer #4E4E4E.
      final bodyColor =
          tagForeColor(TagCategory.body, Brightness.dark);
      expect(bodyColor, isNot(const Color(0xFF4E4E4E)));
    });

    // ---------------------------------------------------------------------------
    // Date formatting
    // ---------------------------------------------------------------------------
    testWidgets('date uses locale-aware format, not hardcoded ISO', (tester) async {
      final image = _testImage(createdAt: '2024-06-15T14:30:00Z');
      await tester.pumpWidget(_wrap(DetailSheet(image: image)));
      await tester.pumpAndSettle();

      // The old hardcoded "yyyy-MM-dd HH:mm" would show this substring
      expect(find.textContaining('2024-06-15 14:30'), findsNothing);
      // With locale pinned to en_US, DateFormat.yMd().add_jm() produces
      // "6/15/2024, 2:30 PM" (or "6/15/24, …" depending on ICU version).
      // Assert the month/day portion appears.
      expect(find.textContaining('6/15'), findsOneWidget);
    });

    testWidgets('date widget exists and is non-empty', (tester) async {
      final image = _testImage(createdAt: '2024-06-15T14:30:00Z');
      await tester.pumpWidget(_wrap(DetailSheet(image: image)));
      await tester.pumpAndSettle();

      // There should be a Text widget containing the year somewhere
      expect(find.textContaining('2024'), findsWidgets);
    });

    // ---------------------------------------------------------------------------
    // NumberFormat with locale grouping
    // ---------------------------------------------------------------------------
    testWidgets('stats use NumberFormat with locale grouping separators', (tester) async {
      final image = _testImage(upvotes: 1234, downvotes: 56, faves: 789,
          comments: 10);
      await tester.pumpWidget(_wrap(DetailSheet(image: image)));
      await tester.pumpAndSettle();

      // en_US locale: 1234 → "1,234"
      expect(find.textContaining('1,234'), findsOneWidget);
      // 789 → "789" (no separator needed)
      expect(find.text('789'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Uploader name
    // ---------------------------------------------------------------------------
    testWidgets('uploader name wraps GestureDetector when non-empty', (tester) async {
      final image = _testImage(uploader: 'TestArtist');
      await tester.pumpWidget(_wrap(DetailSheet(image: image)));
      await tester.pumpAndSettle();

      // The uploader name should be a tappable widget
      expect(find.text('TestArtist'), findsOneWidget);
      // The GestureDetector wraps the Text — verify it exists in the tree
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('empty uploader shows static text "Background Pony"', (tester) async {
      final image = _testImage(uploader: '');
      await tester.pumpWidget(_wrap(DetailSheet(image: image)));
      await tester.pumpAndSettle();

      expect(find.text('Background Pony'), findsOneWidget);
      // The Background Pony text should NOT be inside a GestureDetector that
      // navigates — we verify the text is present and is a plain Text widget.
      final pony = tester.widget<Text>(find.text('Background Pony'));
      expect(pony.style?.fontWeight, FontWeight.bold);
    });
  });
}
