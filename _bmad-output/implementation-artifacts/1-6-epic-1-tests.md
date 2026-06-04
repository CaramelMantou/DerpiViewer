# Story 1.6: Write Epic 1 Tests

Status: ready-for-dev

## Story

As a developer,
I want automated tests for the repositories, strategies, sealed classes, and DI container built in Epic 1,
so that the Epic 1 refactoring is safely validated before subsequent work continues.

## Acceptance Criteria

1. **Given** `test/core/domain/result_test.dart`
   **When** `flutter test` runs
   **Then** tests verify: `Success<T>` holds data, `Failure<T>` holds message + type + error, pattern matching works with exhaustive switch

2. **Given** `test/core/data/datasources/strategies/philomena_v1_strategy_test.dart` + `philomena_v3_strategy_test.dart`
   **When** `flutter test` runs
   **Then** tests verify with fixture JSON files: `parseImageList` returns correct count of ImageDto, `parseFeatured` returns correct image, v1 extracts from `data["images"]`, v3 extracts from `data["posts"]`

3. **Given** `test/core/data/repositories/image_repository_impl_test.dart`
   **When** `flutter test` runs with mock Dio + mock ApiStrategy
   **Then** tests verify: searchImages returns correctly mapped Success<List<ImageEntity>>, DioException maps to correct FailureType, retry fires at Dio interceptor level

4. **Given** `test/core/di/injection_container_test.dart`
   **When** `flutter test` runs
   **Then** tests verify: all get_it registrations resolve without exceptions, `getIt<ImageRepository>()` returns ImageRepositoryImpl instance, `getIt<FavoritesRepository>()` returns FavoritesRepositoryImpl instance

5. **Given** all tests execute
   **When** `flutter test` runs the full suite
   **Then** all tests pass with zero failures

## Tasks / Subtasks

- [ ] Task 1: Add `mocktail` dev dependency + test fixtures (AC: 2)
  - [ ] Add `mocktail: ^1.0.0` to dev_dependencies in pubspec.yaml
  - [ ] Run `flutter pub get`
  - [ ] Create `test/fixtures/derpi_image.json` — sample v1 single image response
  - [ ] Create `test/fixtures/trixie_search.json` — sample v1 search results
  - [ ] Create `test/fixtures/twi_featured.json` — sample v3 featured post
  - [ ] Load fixtures as `Map<String, dynamic>` using `jsonDecode` + test resource loading

- [ ] Task 2: Write Result + ViewState unit tests (AC: 1)
  - [ ] File: `test/core/domain/result_test.dart`
  - [ ] Test: `Success<int>` wraps value correctly
  - [ ] Test: `Failure<String>` stores message, type, error, stackTrace
  - [ ] Test: exhaustive switch on Result compiles and covers both variants
  - [ ] File: `test/core/domain/view_state_test.dart`
  - [ ] Test: LoadingState does not carry data
  - [ ] Test: SuccessState carries data
  - [ ] Test: FailureState carries message + type
  - [ ] Test: exhaustive switch on ViewState covers all three variants

- [ ] Task 3: Write BooruApiStrategy tests (AC: 2)
  - [ ] File: `test/core/data/datasources/strategies/philomena_v1_strategy_test.dart`
  - [ ] Test: parseImageList extracts correct count from fixture
  - [ ] Test: parseFeatured extracts image from `data["image"]`
  - [ ] Test: parseImage extracts correct fields (id, format, tags, urls)
  - [ ] File: `test/core/data/datasources/strategies/philomena_v3_strategy_test.dart`
  - [ ] Test: parseImageList extracts from `data["posts"]`
  - [ ] Test: parseFeatured extracts from `data["post"]`
  - [ ] Test: searchPath and trendingPath are v3 paths

- [ ] Task 4: Write ImageRepositoryImpl tests (AC: 3)
  - [ ] File: `test/core/data/repositories/image_repository_impl_test.dart`
  - [ ] Create `MockBooruApiStrategy` + `MockDio` using mocktail
  - [ ] Test: searchImages returns Success with mapped entities
  - [ ] Test: getImage returns Success with single entity
  - [ ] Test: getFeaturedImage returns Success
  - [ ] Test: Dio connectionError → FailureType.network
  - [ ] Test: Dio 404 response → FailureType.notFound
  - [ ] Test: Dio 403 response → FailureType.api
  - [ ] Test: Dio timeout → FailureType.timeout

- [ ] Task 5: Write FavoritesRepositoryImpl tests (AC: 4)
  - [ ] File: `test/core/data/repositories/favorites_repository_impl_test.dart`
  - [ ] Create `MockFavoritesLocalSource` using mocktail
  - [ ] Test: toggleFavorite(true) calls localSource with INSERT
  - [ ] Test: toggleFavorite(false) calls localSource with DELETE
  - [ ] Test: isFavorite returns expected boolean
  - [ ] Test: getFavorites returns paginated list
  - [ ] Test: SQLite exception → Failure

- [ ] Task 6: Write DI container test (AC: 4)
  - [ ] File: `test/core/di/injection_container_test.dart`
  - [ ] Test: `configureDependencies()` registers all implementations
  - [ ] Test: `getIt<ImageRepository>()` resolves to ImageRepositoryImpl
  - [ ] Test: `getIt<FavoritesRepository>()` resolves to FavoritesRepositoryImpl
  - [ ] Test: `getIt<FavoritesLocalSource>()` resolves to FavoritesLocalSource
  - [ ] Test: no registration throws on resolve

- [ ] Task 7: Verify full suite (AC: 5)
  - [ ] Run `flutter test` — all pass
  - [ ] Run `flutter analyze` — zero errors
  - [ ] Add `add-tearDown` to reset get_it between test files to prevent leakage

## Dev Notes

### mocktail Setup

```dart
// test/core/data/repositories/image_repository_impl_test.dart
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockBooruApiStrategy extends Mock implements BooruApiStrategy {}

void main() {
  late MockDio mockDio;
  late MockBooruApiStrategy mockStrategy;
  late ImageRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    mockStrategy = MockBooruApiStrategy();
    // Register fallback values for mocktail
    registerFallbackValue(Uri.parse('https://example.com'));
    repository = ImageRepositoryImpl(/* strategy factory that returns mockStrategy */);
  });

  tearDown(() {
    // Reset get_it to prevent test leakage
    getIt.reset();
  });

  test('searchImages returns Success with mapped entities', () async {
    // Arrange
    when(() => mockStrategy.parseImageList(any())).thenReturn([/* ImageDto */]);
    when(() => mockDio.getUri(any())).thenAnswer((_) async => 
      Response(data: {'images': [...]}, statusCode: 200, requestOptions: RequestOptions()));
    
    // Act
    final result = await repository.searchImages(
      booru: Booru.derpi,
      query: 'test',
      params: const SearchParams(),
    );
    
    // Assert
    expect(result, isA<Success<List<ImageEntity>>>());
  });
}
```

### get_it Test Isolation

```dart
// Each test file that uses get_it must:
void main() {
  setUp(() {
    configureDependencies();
  });
  
  tearDown(() {
    getIt.reset(); // Prevent state leakage between test files
  });
}
```

### Test Fixture Files

Create `test/fixtures/` directory with JSON files extracted from real API responses:

```json
// test/fixtures/derpi_image.json
{
  "image": {
    "id": 0,
    "representations": {
      "full": "https://derpicdn.net/img/view/2012/1/2/0.png",
      "large": "https://derpicdn.net/img/view/2012/1/2/0_large.png",
      "medium": "https://derpicdn.net/img/view/2012/1/2/0_medium.png",
      "small": "https://derpicdn.net/img/view/2012/1/2/0_small.png",
      "thumb": "https://derpicdn.net/img/view/2012/1/2/0_thumb.png",
      "thumb_small": "https://derpicdn.net/img/view/2012/1/2/0_thumb_small.png",
      "thumb_tiny": "https://derpicdn.net/img/view/2012/1/2/0_thumb_tiny.png"
    },
    "format": "png",
    "tags": ["safe", "solo"],
    "tag_ids": [1, 2],
    "description": "Test image",
    "created_at": "2012-01-02T00:00:00Z",
    "duration": 0.0,
    "upvotes": 100,
    "downvotes": 10,
    "comment_count": 5,
    "faves": 50,
    "uploader": "TestUploader",
    "source_urls": ["https://example.com"]
  }
}
```

### Files to Create

| File | Purpose |
|------|---------|
| `test/fixtures/derpi_image.json` | v1 single image fixture |
| `test/fixtures/trixie_search.json` | v1 search results fixture |
| `test/fixtures/twi_featured.json` | v3 featured post fixture |
| `test/core/domain/result_test.dart` | Result sealed class tests |
| `test/core/domain/view_state_test.dart` | ViewState sealed class tests |
| `test/core/data/datasources/strategies/philomena_v1_strategy_test.dart` | V1 parsing tests |
| `test/core/data/datasources/strategies/philomena_v3_strategy_test.dart` | V3 parsing tests |
| `test/core/data/repositories/image_repository_impl_test.dart` | ImageRepository impl tests |
| `test/core/data/repositories/favorites_repository_impl_test.dart` | FavoritesRepository impl tests |
| `test/core/di/injection_container_test.dart` | DI container test |

### Files to Modify

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `mocktail: ^1.0.0` to dev_dependencies |
| `pubspec.yaml` | Add assets declaration for test fixtures if needed |

### Test Architecture Alignment

Per the Architecture Decision Document testing strategy:
- **Repository tests** (highest ROI) — mock Dio + mock sqflite, test Result mapping and error handling ✅
- **Strategy tests** (medium ROI) — test parseImageList/parseFeatured with fixture JSON ✅  
- **DI container test** — verify all registrations resolve ✅
- **Provider tests** — deferred to later stories (needs Widget test infrastructure)

### References

- Architecture: Testing Strategy, mocktail setup, DI Boundary Rule
- Story 1.3: Repository implementations to test
- Story 1.2: Strategy implementations to test
- Story 1.1: Result/ViewState to test, DI container to test
- mocktail docs: https://pub.dev/packages/mocktail

## Dev Agent Record

### Agent Model Used

Claude (BMad create-story workflow)

### Completion Notes List

### File List
