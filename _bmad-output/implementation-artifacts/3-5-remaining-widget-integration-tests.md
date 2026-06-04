---
baseline_commit: (current HEAD)
---

# Story 3.5: Write Remaining Widget and Integration Tests

Status: ready-for-dev

## Story

As a developer,
I want widget tests for the remaining migrated pages and integration tests for key user flows,
so that the full refactoring is validated and all UX fixes are protected against regression.

## Acceptance Criteria

1. **Given** `test/ui/widgets/detail_sheet_test.dart`
   **When** `flutter test` runs
   **Then** tests verify: tag colors use `tagForeColor()` with correct brightness (light foreground on light, dark foreground on dark), date displays with locale formatting (`DateFormat.yMd().add_jm()`), uploader name is tappable when non-empty, uploader "Background Pony" is static text when empty

2. **Given** `test/ui/pages/home_page_test.dart`
   **When** `flutter test` runs with mock providers
   **Then** tests verify: drawer renders all items with AppLocalizations strings (not hardcoded Chinese), dark mode switch toggles theme via `PrefModel.toggleDarkMode()`, booru switch triggers data reload via `PrefModel.changeHost()`

3. **Given** `test/integration/search_flow_test.dart`
   **When** `flutter test integration_test/search_flow_test.dart` runs with mock HTTP
   **Then** tests verify: open app → tap search FAB → type query → see results → tap result → see gallery → swipe → see next image

4. **Given** `test/integration/favorites_flow_test.dart`
   **When** `flutter test integration_test/favorites_flow_test.dart` runs
   **Then** tests verify: open gallery → tap heart → toast confirms → navigate to favorites → see favorited image → unfavorite → return to favorites → image is gone

5. **Given** all test files from Epics 1, 2, and 3
   **When** `flutter test` runs the full suite
   **Then** all tests pass with zero failures
   **And** `flutter analyze` passes with zero errors

## Tasks / Subtasks

- [ ] Task 1: Write DetailSheet widget test (AC: 1)
  - [ ] Create `test/ui/widgets/detail_sheet_test.dart`
  - [ ] Test: light theme → tag foreground uses `tagForeColorsLight` values
  - [ ] Test: dark theme → tag foreground uses `tagForeColorsDark` values (verify body category no longer 1.9:1 contrast)
  - [ ] Test: date displays locale-aware format (not hardcoded `yyyy-MM-dd HH:mm`)
  - [ ] Test: stats display with NumberFormat grouping separators
  - [ ] Test: uploader name is tappable (`GestureDetector` exists) when non-empty
  - [ ] Test: "Background Pony" is static `Text` (no `onTap`) when uploader is empty

- [ ] Task 2: Write HomePage widget test (AC: 2)
  - [ ] Create `test/ui/pages/home_page_test.dart`
  - [ ] Test: drawer renders all items with l10n strings (Clear Cache / 清除缓存, About / 关于, etc.)
  - [ ] Test: drawer dark mode Switch toggles `PrefModel` dark mode state
  - [ ] Test: drawer booru selector triggers `changeHost()` + AppBar title updates
  - [ ] Test: FABs exist — favorites (always enabled) and search (enabled/disabled per connectivity)
  - [ ] Test: offline banner `MaterialBanner` renders when `ConnectivityProvider.isOnline == false`

- [ ] Task 3: Write search flow integration test (AC: 3)
  - [ ] Create `integration_test/search_flow_test.dart`
  - [ ] Note: Require `integration_test` dev_dependency in pubspec.yaml
  - [ ] Test: pump app → find search FAB → tap → type "safe" in text field → submit → verify ResultPage appears
  - [ ] Test: tap first result → verify GalleryView opens → verify toolbar icons exist
  - [ ] Note: Use mock HTTP to avoid real network calls (consider using `MockDio` or an HTTP override)

- [ ] Task 4: Write favorites flow integration test (AC: 4)
  - [ ] Create `integration_test/favorites_flow_test.dart`
  - [ ] Test: pump app → navigate to gallery of a known image → tap heart icon → verify toast "Faved"
  - [ ] Test: navigate back → tap favorites FAB → verify FavouritePage shows the image
  - [ ] Test: unfavorite → verify image removed from grid
  - [ ] Note: Requires mock favorites data (pre-seeded SQLite or mock Repository)

- [ ] Task 5: Run full validation (AC: 5)
  - [ ] `flutter analyze` — zero errors
  - [ ] `flutter test` — full suite passes (all Epic 1 + 2 + 3 tests)
  - [ ] `flutter test integration_test/` — integration tests pass

## Dev Notes

### Existing Test Inventory (14 files, baseline)

```
test/
├── fixtures/
│   ├── derpi_image.json          # V1 API single image fixture
│   ├── trixie_search.json        # V1 API search results fixture
│   └── twi_featured.json         # V3 API featured image fixture
├── helpers/
│   └── fixture_helper.dart       # loadFixture() helper
├── core/
│   ├── domain/
│   │   ├── result_test.dart              # Result<T> sealed class
│   │   └── view_state_test.dart          # ViewState<T> sealed class
│   ├── data/
│   │   ├── datasources/strategies/
│   │   │   ├── philomena_v1_strategy_test.dart
│   │   │   └── philomena_v3_strategy_test.dart
│   │   └── repositories/
│   │       ├── favorites_repository_impl_test.dart
│   │       ├── image_repository_impl_test.dart
│   │       └── error_mapper_test.dart
│   └── di/
│       └── injection_container_test.dart
├── config/
│   └── tag_categories_test.dart          # Du  al-theme color contrast
├── ui/
│   ├── pages/
│   │   └── fav_page_test.dart            # FavouritePage widget + provider
│   ├── providers/
│   │   └── favorites_provider_test.dart  # FavoritesProvider unit
│   └── widgets/
│       └── gallery_toolbar_scrim_test.dart
├── trending_provider_test.dart
└── widget_test.dart                      # Generic smoke test
```

**Note:** Current test count is approximately 104 tests (as reported after Story 3.3).

### Test Patterns to Follow

#### Mock Setup (mocktail)

```dart
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSearchInterface extends Mock implements SearchInterface {}
class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Register fallback values for mocktail
  });

  // ...
}
```

#### Widget Test Wrapper

```dart
Widget createTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.defaultTheme,
    darkTheme: AppTheme.darkTheme,
    home: Scaffold(body: child),
  );
}

testWidgets('detail sheet shows tags with theme colors', (tester) async {
  final image = ImageResponse(/* ... */);
  await tester.pumpWidget(createTestApp(DetailSheet(image: image)));
  await tester.pumpAndSettle();
  // assertions...
});
```

#### Provider Test Pattern

```dart
test('dark mode toggle updates isDarkMode', () async {
  final prefs = PrefModel();
  await prefs.getPref();
  expect(prefs.isDarkMode, false);
  prefs.toggleDarkMode();
  expect(prefs.isDarkMode, true);
});
```

### DetailSheet Widget Test (Task 1)

**Test cases:**

```dart
group('DetailSheet', () {
  final testImage = ImageResponse(
    id: 1,
    booru: Booru.derpi,
    tags: ['safe', 'pony', 'artist:tester'],
    tagids: [1, 2, 3],
    description: 'Test description',
    createdAt: '2024-01-01T12:00:00Z',
    upvotes: 1234, downvotes: 56, faves: 789, comments: 10,
    uploader: 'TestArtist', sourceUrls: [],
    // ... other required fields
  );

  testWidgets('renders tag chips with category colors', (tester) async {
    await tester.pumpWidget(createTestApp(DetailSheet(image: testImage)));
    await tester.pumpAndSettle();
    // Chip widgets present
    expect(find.byType(Chip), findsWidgets);
  });

  testWidgets('date uses locale-aware format', (tester) async {
    await tester.pumpWidget(createTestApp(DetailSheet(image: testImage)));
    await tester.pumpAndSettle();
    // Should NOT contain "2024-01-01 12:00" (old hardcoded format)
    expect(find.textContaining('2024-01-01'), findsNothing);
  });

  testWidgets('stats use NumberFormat with locale grouping', (tester) async {
    await tester.pumpWidget(createTestApp(DetailSheet(image: testImage)));
    await tester.pumpAndSettle();
    // Comma-separated thousands for en_US
    expect(find.textContaining('1,234'), findsOneWidget);
  });

  testWidgets('uploader name is tappable GestureDetector when non-empty', (tester) async {
    await tester.pumpWidget(createTestApp(DetailSheet(image: testImage)));
    await tester.pumpAndSettle();
    expect(find.text('TestArtist'), findsOneWidget);
  });

  testWidgets('empty uploader shows static Text "Background Pony"', (tester) async {
    final anon = ImageResponse(/* ... */ uploader: '', /* ... */);
    await tester.pumpWidget(createTestApp(DetailSheet(image: anon)));
    await tester.pumpAndSettle();
    expect(find.text('Background Pony'), findsOneWidget);
  });
});
```

**Note:** `ImageResponse` constructor requires all fields. Create a helper:

```dart
ImageResponse createTestImageResponse({
  int id = 1,
  String uploader = 'TestArtist',
  List<String> tags = const ['safe'],
  List<int> tagids = const [1],
  int upvotes = 1234,
  int downvotes = 56,
  int faves = 789,
  int comments = 10,
  String createdAt = '2024-01-01T12:00:00Z',
}) {
  return ImageResponse(
    id: id,
    booru: Booru.derpi,
    fullUrl: 'https://example.com/full.png',
    smallUrl: 'https://example.com/small.png',
    mediumUrl: 'https://example.com/medium.png',
    largeUrl: 'https://example.com/large.png',
    thumbUrl: 'https://example.com/thumb.png',
    thumbSmallUrl: 'https://example.com/thumb_small.png',
    thumbTinyUrl: 'https://example.com/thumb_tiny.png',
    format: ContentFormat.png,
    tags: tags,
    tagids: tagids,
    description: 'Test description',
    createdAt: createdAt,
    duration: 0.0,
    upvotes: upvotes,
    downvotes: downvotes,
    comments: comments,
    faves: faves,
    uploader: uploader,
    sourceUrls: [],
  );
}
```

### HomePage Widget Test (Task 2)

```dart
group('HomePage', () {
  testWidgets('drawer items use l10n strings', (tester) async {
    await tester.pumpWidget(createTestApp(const HomePage()));
    await tester.pumpAndSettle();
    // Open drawer
    await tester.tap(find.byTooltip('Open navigation menu'));
    // Or: Scaffold.of(tester.element(find.byType(HomePage))).openDrawer();
    await tester.pumpAndSettle();
    // Verify drawer items use l10n (not hardcoded Chinese)
    expect(find.text('Clear Cache'), findsOneWidget);   // drawerClearCache
    expect(find.text('About'), findsOneWidget);           // drawerAbout
    expect(find.text('Dark Mode'), findsOneWidget);       // drawerDarkMode
    expect(find.text('Single Column Mode'), findsOneWidget);
  });

  testWidgets('FABs exist with tooltips', (tester) async {
    await tester.pumpWidget(createTestApp(const HomePage()));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favorites'), findsOneWidget);
    expect(find.byTooltip('Search'), findsOneWidget);
  });
});
```

**Note:** Since `HomePage` now uses `ConnectivityProvider`, wrap in test:

```dart
Widget createHomePageTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PrefModel()),
      ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ),
  );
}
```

### Integration Tests (Tasks 3 & 4)

Integration tests require `integration_test` package:

```yaml
# pubspec.yaml — add dev_dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.0
```

**`integration_test/search_flow_test.dart`:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:derpiviewer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search flow end-to-end', (tester) async {
    await tester.pumpWidget(const app.DVApp());
    await tester.pumpAndSettle();
    // Note: Real HTTP calls will fire. For deterministic tests,
    // consider using a mock HTTP interceptor or running against a
    // test booru instance.
    //
    // Find + tap search FAB
    // await tester.tap(find.byTooltip('Search'));
    // ... type query, submit, verify results
  });
}
```

**`integration_test/favorites_flow_test.dart`:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('favorites flow end-to-end', (tester) async {
    await tester.pumpWidget(/* full app widget */);
    await tester.pumpAndSettle();
    // Note: Requires pre-seeded favorites in SQLite for deterministic runs
    // Or use mock Repository overrides
  });
}
```

### Files to Create

| File | Purpose |
|------|---------|
| `test/ui/widgets/detail_sheet_test.dart` | DetailSheet tag colors, date, numbers, uploader tap |
| `test/ui/pages/home_page_test.dart` | HomePage drawer l10n, toggles, FABs |
| `integration_test/search_flow_test.dart` | End-to-end search flow |
| `integration_test/favorites_flow_test.dart` | End-to-end favorites flow |

### Files to Modify

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `integration_test` to dev_dependencies if not present |

### Preserved Behaviors (MUST NOT BREAK)

- All 104+ existing tests must continue to pass
- flutter analyze must remain at zero errors
- Test fixtures (JSON files) must remain unchanged
- mocktail Mock class patterns must be consistent with existing tests
- SharedPreferences.setMockInitialValues() pattern consistent
- Test Widgets Flutter Binding initialization consistent

### References

- [Epics: Story 3.5](_bmad-output/planning-artifacts/epics.md#story-35-write-remaining-widget-and-integration-tests)
- [Story 1.6: Epic 1 Tests](_bmad-output/implementation-artifacts/1-6-epic-1-tests.md) — test patterns, mocktail setup, fixture strategy
- [Architecture: Testing Strategy](_bmad-output/planning-artifacts/architecture.md#testing-strategy) — Layered testing, mock strategy
- [Architecture: Test Organization](_bmad-output/planning-artifacts/architecture.md#test-organization) — test/ mirrors lib/ structure
- [Flutter integration_test docs](https://docs.flutter.dev/testing/integration-tests)
- [mocktail pub.dev](https://pub.dev/packages/mocktail)
- Existing tests: 14 files across `test/` directory

## Dev Agent Record

### Agent Model Used

Claude (BMad create-story workflow)

### Completion Notes List

- Story 3.5 created — final story in Epic 3, completing the full 14-story refactoring
- 4 new test files: 2 widget tests (detail_sheet, home_page) + 2 integration tests (search, favorites)
- Covers all remaining UX-DRs that need test coverage: tag contrast (UX-DR7), date locale (UX-DR12), number formatting (UX-DR13), uploader tap (UX-DR21), offline banner (UX-DR4)
- Follows established mocktail test patterns from Epic 1-2 tests
- integration_test package required for end-to-end flow tests
- All existing 104+ tests must continue passing — zero regression

### File List
