---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
workflowType: 'architecture'
lastStep: 8
status: 'complete'
completedAt: '2026-06-04'
inputDocuments:
  - docs/index.md
  - docs/architecture.md
  - docs/project-overview.md
  - docs/component-inventory.md
  - docs/api-contracts.md
  - docs/data-models.md
  - docs/source-tree-analysis.md
  - docs/development-guide.md
workflowType: 'architecture'
project_name: 'derpiviewer'
user_name: 'V3rgil'
date: '2026-06-04'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements (from existing codebase):**
1. Multi-booru browsing — 7 Philomena-powered booru hosts, each with independent filter configurations
2. Featured/Trending images — infinite-scroll trending feed with featured image banner
3. Search — full-text query with configurable sort field, sort direction, and per-booru filter
4. Gallery viewer — full-screen photo viewer with pinch-to-zoom + slideshow mode with configurable interval
5. Local favorites — SQLite-backed CRUD with favorite state toggle
6. Download management — download images/videos at selectable resolution
7. Share — share image files or image links
8. Dark mode — toggleable light/dark Material theme
9. Layout preferences — single/dual column grid toggle + configurable image sizes
10. i18n — English + Simplified Chinese
11. Cache management — separate image and video cache clearing

**Refactoring Goals (Non-Functional Requirements):**
1. Low module coupling — clear separation between layers
2. Agent-friendly development — patterned code where an agent can read an ~80-line file and fully understand it
3. Testability — currently zero; enable unit, widget, and integration testing
4. Dependency injection — replace singletons and static methods for mockability
5. Repository layer — create abstractions for API and database access

### Scale & Complexity

- **Primary domain:** Mobile (Flutter/Dart) + REST API consumption
- **Complexity level:** Low-Medium (single Flutter app, ~20 source files, ~1100 LOC)
- **Data complexity:** Low — single SQLite table, SharedPreferences key-value
- **UI complexity:** Medium — image grids, zoomable gallery, video playback, slideshow
- **Integration complexity:** Low — REST API only, no push, no WebSocket, no third-party auth
- **Estimated target components:** ~30-35 files (after splitting, without UseCase and freezed)

### Technical Constraints & Dependencies

- **Flutter 3.32.7 / Dart 3.8.1** — framework version is fixed
- **Android minSdk 21** — constrains certain package choices
- **Provider** — already in use; migrating to Riverpod/BLoC would require full state layer rewrite
- **sqflite** — mobile-only SQLite; cannot test on desktop without `sqflite_common_ffi`

### Cross-Cutting Concerns Identified

1. **API Communication** — touches every model and data source (Dio HTTP → 7 booru hosts)
2. **State Management** — Provider + ChangeNotifier across 4 models; preferences are the driving dependency
3. **Local Persistence** — Favorites (SQLite) + Preferences (SharedPreferences) + Image cache
4. **Image/Video Handling** — Multi-resolution URL selection, caching, download, share
5. **Error Handling** — Currently near-nonexistent; silent failure swallowing at all layers
6. **i18n** — Strings must remain accessible throughout the UI layer

### Agent-Friendliness Definition

"Agent-friendly" for this project means:
1. **Agent can add a new Booru adapter** — Strategy pattern + config map makes this a single-file addition
2. **Agent can fix a UI bug** — Widget files are small, single-responsibility, with explicit state contracts
3. **Agent can generate a new page from scratch** — Follows Provider + ViewState pattern template, copies from existing pages

## Starter Template Evaluation

**Note:** This is a brownfield refactoring, not a greenfield project. "Starter" decisions are foundational architectural dependencies we introduce to support the refactoring goals.

### Primary Technology Domain

Flutter/Dart mobile application (Android) — fixed by existing codebase.

### Foundation Decisions

#### Dependency Injection: `get_it`

**Rationale:** Lightest migration cost. Works alongside existing Provider setup. Agent-recognizable pattern: `getIt<Repository>()`.

#### State Management: Keep Provider

**Rationale:** Zero migration cost. Standard Flutter pattern agents can read. Riverpod migration would be a separate project.

#### Data Classes: Simple Dart (no freezed)

**Rationale:** At ~1100 LOC, manual `==` and `copyWith` is less overhead than build_runner + code generation. Freezed would introduce CI complexity, build time, and mocktail compatibility issues (deep-compare `==` vs verify). If the project grows beyond ~3000 LOC, reconsider freezed.

#### Testing: `mocktail`

**Rationale:** No code generation required. Once DI is in place, mocking becomes trivial: `final mockRepo = MockImageRepository();`

### Additions to pubspec.yaml

```yaml
dependencies:
  get_it: ^8.0.0

dev_dependencies:
  mocktail: ^1.0.0
```

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
1. Repository pattern — abstract contracts for data access → enables testability
2. BooruApiStrategy pattern — eliminates `if (booru == Booru.twi)` branching
3. ViewState<T> UI state pattern — loading/success/failure in one sealed class
4. DI boundary rule — get_it only at composition root

**Important Decisions (Shape Architecture):**
5. Provider directly calls Repository (no UseCase layer)
6. Result<T> for data layer, ViewState<T> for UI layer
7. Dio interceptors + unified error mapping
8. File splits by responsibility

**Deferred Decisions (Post-MVP):**
- Riverpod migration — separate future project
- Deep link support — no router currently needed
- Remote filter config — hardcoded filter IDs acceptable for now

### Data Architecture

**Decision: Repository Pattern + Data Source Abstraction (No UseCase Layer)**

Provider calls Repository directly. UseCase extracted only when a Provider coordinates 2+ different Repositories. This avoids speculative generality for a ~1100 LOC codebase.

```
lib/core/
├── domain/
│   ├── entities/
│   │   └── image_entity.dart              (simple Dart, immutable)
│   ├── repositories/
│   │   ├── image_repository.dart          (abstract interface)
│   │   └── favorites_repository.dart      (abstract interface)
│   ├── enums/                             (pure enums, no Flutter deps)
│   │   ├── booru.dart
│   │   ├── sort_field.dart
│   │   ├── sort_direction.dart
│   │   ├── content_format.dart
│   │   └── tag_category.dart
│   ├── result.dart                        (Result<T> sealed: Success|Failure)
│   └── view_state.dart                    (ViewState<T> sealed: Loading|Success|Failure)
├── data/
│   ├── datasources/
│   │   ├── strategies/
│   │   │   ├── booru_api_strategy.dart    (abstract)
│   │   │   ├── philomena_v1_strategy.dart
│   │   │   └── philomena_v3_strategy.dart
│   │   ├── philomena_remote_source.dart
│   │   └── favorites_local_source.dart
│   ├── repositories/
│   │   ├── image_repository_impl.dart
│   │   └── favorites_repository_impl.dart
│   └── dtos/
│       └── image_dto.dart                 (simple class, manual fromJson)
└── di/
    ├── injection_container.dart           (get_it registrations)
    └── app_module.dart                    (Provider wiring via get_it)
```

**Key Interface Contracts:**

```dart
// domain/repositories/image_repository.dart
abstract class ImageRepository {
  Future<Result<ImageEntity>> getImage(Booru booru, int id, {String? apiKey});
  Future<Result<List<ImageEntity>>> searchImages({required Booru booru, required String query, required SearchParams params, String? apiKey});
  Future<Result<ImageEntity>> getFeaturedImage(Booru booru, {String? apiKey});
}

// domain/repositories/favorites_repository.dart
abstract class FavoritesRepository {
  Future<Result<List<ImageEntity>>> getFavorites(Booru booru, int page, int perPage);
  Future<Result<void>> toggleFavorite(Booru booru, ImageEntity image, bool isFaved);
  Future<Result<bool>> isFavorite(Booru booru, int imageId);
}
```

**Rationale:** Repository interfaces are the single most important enabler of testability. Models call repositories instead of singletons. Mock implementations replace real data sources. Agents understand data contracts by reading interfaces.

### State Management Architecture

**Decision: Two-level state pattern — Result\<T\> for data layer, ViewState\<T\> for UI layer**

```dart
// domain/result.dart — Data layer return type
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends Result<T> {
  final String message;
  final FailureType type;  // NetworkFailure, ApiFailure, NotFound, TimeoutFailure, DeserializationFailure
  final Object? error;
  final StackTrace? stackTrace;
  const Failure(this.message, {required this.type, this.error, this.stackTrace});
}

// domain/view_state.dart — UI layer state
sealed class ViewState<T> {
  const ViewState();
}
class LoadingState<T> extends ViewState<T> {
  const LoadingState();
}
class SuccessState<T> extends ViewState<T> {
  final T data;
  const SuccessState(this.data);
}
class FailureState<T> extends ViewState<T> {
  final String message;
  final FailureType type;
  const FailureState(this.message, {required this.type});
}
```

**Provider structure (post-refactor):**

```dart
class SearchProvider extends ChangeNotifier {
  final ImageRepository _repo;
  ViewState<List<ImageEntity>> _state = const LoadingState();
  ViewState<List<ImageEntity>> get state => _state;

  SearchProvider(this._repo);  // injected via get_it at composition root

  Future<void> search(String query) async {
    _state = const LoadingState();
    notifyListeners();

    final result = await _repo.searchImages(
      booru: _prefs.booru,
      query: query,
      params: SearchParams(...),
    );

    _state = switch (result) {
      Success(data: final images) => SuccessState(images),
      Failure(message: final msg, type: final type) => FailureState(msg, type: type),
    };
    notifyListeners();
  }
}
```

**ViewModel State Design Guidelines:**
- Each Provider exposes exactly one `ViewState<T>` getter — one source of truth
- Loading/Success/Failure always handled — UI never needs to check "is there data AND am I loading"
- One-time events (animations, navigation, toasts) use a separate `Stream<T>` channel, not ViewState
- Different page regions may have independent ViewStates — don't collapse gallery loading + toolbar loading into one flag

### DI Boundary Rule

**Decision: get_it ONLY at composition root**

```dart
// main.dart — composition root
void main() async {
  await configureDependencies();  // get_it registrations
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PrefProvider>(
          create: (_) => PrefProvider(getIt<PreferencesRepository>()),
        ),
        ChangeNotifierProxyProvider<PrefProvider, SearchProvider>(
          create: (ctx) => SearchProvider(
            getIt<ImageRepository>(),
            ctx.read<PrefProvider>(),
          ),
          update: (_, prefs, prev) => prev!..onPrefsChanged(prefs),
        ),
      ],
      child: const DVApp(),
    ),
  );
}
```

**Forbidden:** `getIt<T>()` inside any widget's `build()` method, inside any Provider method body, or inside any dialog.
**Allowed:** `getIt<T>()` only inside `main.dart` Provider `create:` callbacks, and inside `configureDependencies()`.

### API & Communication Patterns

**Decision: Booru Strategy Pattern + Dio Interceptors + Unified Error Mapping**

```dart
abstract class BooruApiStrategy {
  String get host;
  String get searchPath;
  String get trendingPath;
  List<ImageDto> parseImageList(Map<String, dynamic> json);
  ImageDto parseImage(Map<String, dynamic> json);
  ImageDto parseFeatured(Map<String, dynamic> json);
}
```

**Strategy lifecycle:** Each strategy holds its own Dio instance with strategy-specific BaseOptions. Registered as get_it factories (not singletons). Switching booru at runtime triggers recreation via factory.

**Strategy selection:** Encapsulated in a `BooruApiStrategyFactory` that maps `Booru` → `BooruApiStrategy`. No `if (booru == Booru.twi)` in any Repository code.

**Dio Configuration:**
- Request/response logging interceptor
- Automatic retry on network error (3 attempts, exponential backoff)
- Configurable timeout (connect: 10s, read: 30s)
- Unified error mapping: DioException → Failure in a single `error_mapper.dart` utility, not repeated in every Repository method

### File Split Plan

**Decision: Split by responsibility, not by line count**

| Before | After | Trigger |
|--------|-------|---------|
| `enums.dart` (255 lines, 8 concerns) | `domain/enums/booru.dart`, `domain/enums/sort_field.dart`, etc. + `config/booru_config.dart` (hosts, paths, filters) + `config/tag_categories.dart` (categories + colors) + `config/constants.dart` (fallback URLs, mime types) | Mixed enums + config + UI colors + l10n helpers |
| `home_page.dart` (323 lines, 3 widgets) | `home_page.dart` + `widgets/trending_scroll.dart` + `widgets/home_drawer.dart` | Three distinct widget responsibilities |
| `search_model.dart` (interface + impl) | `domain/search_interface.dart` (abstract, no Flutter) + `ui/providers/search_provider.dart` (ChangeNotifier) | Interface serves both SearchModel and FavModel |

### Caching Strategy

**Decision: HTTP-level caching via Dio cache interceptor + in-memory LRU for search results**

- **Image thumbnails:** Existing `CachedNetworkImage` + `flutter_cache_manager` stays in place — no change needed
- **API responses:** Added `dio_cache_interceptor` for HTTP response caching (configurable TTL: 5 min for trending, 2 min for search results, 24h for image detail)
- **Search pagination:** Existing `page`/`perPage` offset-based pagination preserved; `Page<T>` DTO wraps results + `hasMore` boolean
- **Favorites:** Local SQLite — no caching layer needed, reads are fast enough

### Testing Strategy

**Decision: Layered testing with mocktail, focused on high-ROI layers**

**Priority order:**
1. **Repository tests** (highest ROI) — mock Dio + mock sqflite, test Result mapping and error handling
2. **Provider tests** (high ROI) — mock Repository, test ViewState transitions (loading→success, loading→failure)
3. **Strategy tests** (medium ROI) — test parseImageList / parseFeatured with fixture JSON from each booru version
4. **Widget tests** (lower priority) — test key user flows with Provider overrides

**Mock strategy:**
- `ImageRepository` → `MockImageRepository implements ImageRepository`
- `FavoritesRepository` → `MockFavoritesRepository implements FavoritesRepository`
- Repository tests inject `MockDio` and `MockDatabase`, not real HTTP/DB
- No interceptor chain in tests — Repository takes an abstracted `ApiClient`, not raw Dio

## Decision Impact Analysis

**Implementation Sequence:**
1. Add `get_it` + `mocktail` to pubspec, create DI container
2. Extract pure enums from `enums.dart` (no config/UI dependency)
3. Create Result<T> + ViewState<T> sealed classes
4. Create Repository interfaces + BooruApiStrategy abstract
5. Implement strategies (v1 + v3) with fixture-based tests
6. Implement Repository implementations with mock Dio injection
7. Migrate Providers one-by-one: inject Repository, use ViewState
8. Split large files
9. Add Dio interceptors + unified error mapper
10. Write Repository and Provider unit tests

**Cross-Component Dependencies:**
- All steps depend on DI container being initialized first
- Provider migration depends on Repository interfaces being registered
- File splits can happen in parallel with Provider migration

## Implementation Patterns & Consistency Rules

### Critical Conflict Points Identified

8 areas where AI agents could make different choices — resolved below to ensure all agents produce compatible code.

### Naming Patterns

**File Naming:** `snake_case` (Dart standard)
- `image_repository.dart`, `search_provider.dart`, `booru_config.dart`

**Class Naming:** `PascalCase`
- `ImageRepository`, `PhilomenaV1Strategy`, `SearchProvider`

**Variable/Method:** `camelCase` (Dart standard)
- `searchImages()`, `getFeaturedImage()`, `isFavorite`

**Abstract Interfaces:** No `I` prefix (Dart convention)
- `ImageRepository` NOT `IImageRepository`
- Implementation: `ImageRepositoryImpl`

### Structure Patterns

**Project Organization:**
```
lib/
├── core/
│   ├── domain/
│   │   ├── entities/       # Plain Dart classes, no Flutter deps
│   │   ├── repositories/   # Abstract interfaces
│   │   └── enums/          # Pure enums only
│   ├── data/
│   │   ├── datasources/    # API + DB implementations
│   │   ├── repositories/   # Interface implementations
│   │   └── dtos/           # JSON-transfer objects
│   └── di/                 # get_it container
├── ui/
│   ├── providers/          # ChangeNotifier classes
│   ├── pages/              # One file per route screen
│   ├── widgets/            # Reusable components
│   └── theme/              # App theme data
├── config/                 # Static configuration
└── l10n/                   # Localization (unchanged)
```

**Test Organization:** `test/` mirrors `lib/` structure
```
test/
├── core/
│   ├── data/
│   │   ├── datasources/strategies/  # Strategy parsing tests
│   │   └── repositories/            # Repository integration tests
│   └── domain/                      # Entity/Result unit tests
├── ui/
│   └── providers/                   # Provider ViewState tests
└── fixtures/                        # JSON response fixtures per booru
```

**Provider Location:** `lib/ui/providers/` — one file per Provider, named `{domain}_provider.dart`

### Format Patterns

**API Response → DTO:** `ImageDto.fromJson(Map<String, dynamic>)` in data layer. DTO is internal to data layer — domain layer only sees `ImageEntity`.
**JSON Fields:** Source API uses `snake_case` (Philomena API). DTO field names match source. Entity field names use `camelCase`. Mapping happens in Repository implementation.
**Date Format:** `DateTime` in Entity/Provider. `String` (RFC3339) in DTO. Parsed during Repository mapping.
**IDs:** `int` throughout — Philomena uses integer IDs.

### Communication Patterns

**ViewState Usage:**
```dart
// Mandatory pattern — exhaustive switch on sealed class
final content = switch (provider.state) {
  LoadingState() => const SkeletonGrid(),
  SuccessState(data: final images) => ImageGrid(images: images),
  FailureState(message: final msg, type: final type) => ErrorView(message: msg, type: type),
};
```

**One-Time Events:** Separate `StreamController<T>` per Provider — NOT embedded in ViewState. Used for: navigation triggers, toast messages, animation kick-off.
```dart
class SearchProvider extends ChangeNotifier {
  final _eventController = StreamController<SearchEvent>.broadcast();
  Stream<SearchEvent> get events => _eventController.stream;
  // Events: SearchSubmitted, NavigateToGallery, ShowToast
}
```

**Error Message Routing:** `FailureType` enum → UI-friendly message via l10n lookup. Never expose raw exception strings to UI.
```dart
String mapFailureToMessage(FailureType type) => switch (type) {
  FailureType.network => AppLocalizations.of(context)!.errorNetwork,
  FailureType.notFound => AppLocalizations.of(context)!.errorNotFound,
  FailureType.timeout => AppLocalizations.of(context)!.errorTimeout,
  FailureType.api => AppLocalizations.of(context)!.errorServer,
  FailureType.deserialization => AppLocalizations.of(context)!.errorUnexpected,
};
```

### Process Patterns

**Loading UI:**
- Image grid: skeleton shimmer (3x2 placeholder cards)
- Gallery view: full-screen `CircularProgressIndicator`
- Action buttons: disable + show mini-spinner on button
- Pull-to-refresh: `RefreshIndicator` wrapping scroll view

**Retry Logic:** Dio interceptors in Repository handle automatic retry (3 attempts, exponential backoff). Providers do NOT implement manual retry — they just re-call the same method. User-facing retry: a "Retry" button in `FailureState` UI that calls the Provider method again.

**Error Handling:**
- Repository: `try-catch DioException` → map to `Failure` via centralized `error_mapper.dart`
- Provider: receives `Failure` from Repository, converts to `FailureState`
- Widget: renders `ErrorView` with retry button + localized message
- Fatal errors: logged via `developer.log()` with stack trace

### Enforcement Guidelines

**All AI Agents MUST:**
- Use `snake_case` for filenames
- Use `ViewState<T>` sealed class pattern for every async Provider
- Never call `getIt<T>()` outside composition root
- Never expose raw exception messages to UI
- Place tests in `test/` mirroring `lib/` path
- Use `switch` exhaustion (not `if-else`) for sealed class handling
- Separate one-time events into `StreamController`, not ViewState

**Pattern Verification:**
- `dart analyze` catches naming convention violations
- Code review checklist: check `getIt` usage, file naming, ViewState pattern
- Test coverage gates: Repository + Provider tests required per story

## Project Structure & Boundaries

### Complete Project Directory Structure

```
derpiviewer/
├── android/                              # Android platform (unchanged)
├── assets/
│   └── derpy.png                         # App icon
├── lib/
│   ├── main.dart                         # Entry point + Provider wiring (thinned)
│   │
│   ├── core/                             # Framework-free layer
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── image_entity.dart     # Immutable Image entity
│   │   │   ├── repositories/
│   │   │   │   ├── image_repository.dart         # Abstract interface
│   │   │   │   └── favorites_repository.dart     # Abstract interface
│   │   │   ├── enums/
│   │   │   │   ├── booru.dart
│   │   │   │   ├── sort_field.dart
│   │   │   │   ├── sort_direction.dart
│   │   │   │   ├── content_format.dart
│   │   │   │   ├── tag_category.dart
│   │   │   │   └── size.dart
│   │   │   ├── result.dart               # Result<T> sealed class
│   │   │   ├── view_state.dart           # ViewState<T> sealed class
│   │   │   ├── failure_type.dart         # FailureType enum
│   │   │   ├── search_params.dart        # Search params value object
│   │   │   └── search_interface.dart     # Abstract UI contract
│   │   │
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── strategies/
│   │   │   │   │   ├── booru_api_strategy.dart        # Abstract strategy
│   │   │   │   │   ├── philomena_v1_strategy.dart     # derpi/trixie/pony/fur/ponerpics/mane
│   │   │   │   │   └── philomena_v3_strategy.dart     # twi
│   │   │   │   ├── philomena_remote_source.dart       # HTTP implementation
│   │   │   │   └── favorites_local_source.dart        # SQLite implementation
│   │   │   ├── repositories/
│   │   │   │   ├── image_repository_impl.dart
│   │   │   │   └── favorites_repository_impl.dart
│   │   │   ├── dtos/
│   │   │   │   └── image_dto.dart                     # JSON transfer object
│   │   │   └── error_mapper.dart                      # DioException → Failure
│   │   │
│   │   └── di/
│   │       └── injection_container.dart               # get_it registrations
│   │
│   ├── ui/                               # Flutter UI layer
│   │   ├── app.dart                      # DVApp MaterialApp
│   │   ├── providers/
│   │   │   ├── pref_provider.dart
│   │   │   ├── search_provider.dart
│   │   │   ├── trending_provider.dart    # extends SearchProvider
│   │   │   └── fav_provider.dart
│   │   ├── pages/
│   │   │   ├── home_page.dart
│   │   │   ├── search_page.dart
│   │   │   ├── result_page.dart
│   │   │   ├── fav_page.dart
│   │   │   └── gallery.dart
│   │   ├── widgets/
│   │   │   ├── trending_scroll.dart      # Split from home_page
│   │   │   ├── home_drawer.dart          # Split from home_page
│   │   │   ├── image_grid.dart
│   │   │   ├── detail_sheet.dart
│   │   │   ├── gallery_toolbar.dart
│   │   │   ├── video_view.dart
│   │   │   ├── fav_icon.dart
│   │   │   ├── error_view.dart           # Reusable error state widget
│   │   │   └── dialogs/
│   │   │       ├── booru_dialog.dart
│   │   │       ├── search_params_dialog.dart
│   │   │       ├── download_prefs_dialog.dart
│   │   │       ├── api_key_dialog.dart
│   │   │       ├── cache_dialog.dart
│   │   │       ├── about_dialog.dart
│   │   │       └── slideshow_dialog.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   │
│   ├── config/                           # Static configuration
│   │   ├── booru_config.dart             # Hosts, paths, filter maps
│   │   ├── tag_categories.dart           # Tag categories + colors
│   │   └── constants.dart                # Fallback URLs, MIME types
│   │
│   └── l10n/                             # Localization (unchanged)
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       ├── app_localizations_zh.dart
│       ├── app_en.arb
│       └── app_zh.arb
│
├── test/
│   ├── fixtures/
│   │   ├── derpi_image.json
│   │   ├── trixie_search.json
│   │   └── twi_featured.json
│   ├── core/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── strategies/
│   │   │   │   │   ├── philomena_v1_strategy_test.dart
│   │   │   │   │   └── philomena_v3_strategy_test.dart
│   │   │   │   └── favorites_local_source_test.dart
│   │   │   └── repositories/
│   │   │       ├── image_repository_impl_test.dart
│   │   │       └── favorites_repository_impl_test.dart
│   │   └── domain/
│   │       ├── image_entity_test.dart
│   │       └── result_test.dart
│   └── ui/
│       └── providers/
│           ├── search_provider_test.dart
│           └── fav_provider_test.dart
│
├── docs/                                 # Project documentation (existing)
├── _bmad-output/
│   └── planning-artifacts/
│       └── architecture.md               # This document
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── philomena_api.md
└── README.md
```

### Architectural Boundaries

**Domain Boundary:** `core/domain/` — no Flutter imports, no `ui/` imports. Pure Dart. Contains entities, interfaces, enums, value objects.
**Data Boundary:** `core/data/` — may import `domain/` only. Contains implementations, DTOs, data sources.
**DI Boundary:** `core/di/` — composition root. get_it registrations ONLY. References all other layers.
**UI Boundary:** `ui/` — may import `domain/` (for entities, interfaces, ViewState). May NOT import `data/` or `di/`.

**Cross-Boundary Rule:**
- `domain/` ← imported by everything
- `data/` ← imported by `di/` only
- `di/` ← imported by `main.dart` only
- `ui/` ← imports `domain/` only, receives implementations via constructor injection

### Requirements to Structure Mapping

| Feature | Location |
|---------|----------|
| Multi-booru browsing | `config/booru_config.dart` + `strategies/` |
| Trending feed | `ui/providers/trending_provider.dart` + `widgets/trending_scroll.dart` |
| Search | `ui/providers/search_provider.dart` + `pages/search_page.dart` + `pages/result_page.dart` |
| Gallery viewer | `pages/gallery.dart` + `widgets/gallery_toolbar.dart` + `ui/providers/` |
| Favorites | `favorites_repository.dart` + `datasources/favorites_local_source.dart` + `ui/providers/fav_provider.dart` |
| Download/Share | `helpers/` (keep existing location) |
| Dark mode | `ui/providers/pref_provider.dart` + `theme/app_theme.dart` |
| Config/Settings | `config/` files + `core/domain/enums/` |

### Integration Points

**Data Flow:** UI → Provider.fetchMore() → Repository.searchImages() → ApiStrategy → Dio → Philomena API
**DI Flow:** main.dart → injection_container.dart → get_it registers implementations → Provider receives via constructor
**Error Flow:** DioException → error_mapper.dart → Failure → Provider → FailureState → ErrorView widget

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:** All technology choices (Flutter 3.32.7, Dart 3.8.1, Provider, get_it, mocktail, Dio, sqflite) are compatible. Dart 3 sealed classes natively support ViewState/Result patterns. No version conflicts.

**Pattern Consistency:** ViewState and Result patterns are complementary (Result for data layer, ViewState for UI layer). Naming conventions (snake_case files, PascalCase classes) align with Dart platform standards. Structure patterns enforce clear domain/data/ui/di layer boundaries.

**Structure Alignment:** Project tree maps directly to architectural decisions. Each decision category has physical file locations. Boundary rules prevent import violations between layers.

### Requirements Coverage Validation ✅

**Functional Requirements Coverage:** All 11 FRs have architectural support with specific file locations mapped.

**Non-Functional Requirements Coverage:**
- Low coupling → Repository + Strategy + layer boundaries with import rules
- Agent-friendly → Pattern documentation + single-responsibility files + explicit conventions
- Testability → DI via get_it + mocktail + layered testing strategy
- Dependency injection → get_it composition-root-only rule
- Repository layer → ImageRepository + FavoritesRepository abstract interfaces

### Implementation Readiness Validation ✅

**Decision Completeness:** All critical decisions documented. Starter foundations chosen. No missing architectural capabilities.

**Structure Completeness:** Every file in the target project tree is named and located. Boundaries defined with import rules. Test structure mirrors source structure.

**Pattern Completeness:** 8 potential agent conflict points identified and resolved. Naming, structure, format, communication, and process patterns all documented with code examples.

### Architecture Completeness Checklist

**Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**Architectural Decisions**
- [x] Critical decisions documented with versions
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**Implementation Patterns**
- [x] Naming conventions established
- [x] Structure patterns defined
- [x] Communication patterns specified
- [x] Process patterns documented

**Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** ✅ READY FOR IMPLEMENTATION

**Confidence Level:** High — all 16 checklist items verified, no critical gaps.

**Key Strengths:**
- Clear layer boundaries with import rules prevent coupling regression
- ViewState< T> + Result< T> dual pattern covers all async states explicitly
- BooruApiStrategy eliminates the most fragile branching code in the current codebase
- Composition-root-only DI rule prevents Service Locator anti-pattern
- Complete project tree with named files gives agents a navigation map
- Pattern examples (good code vs anti-patterns) guide consistent implementation

**Areas for Future Enhancement:**
- CI/CD pipeline definition (GitHub Actions for flutter analyze + flutter test)
- E2E/integration testing strategy (currently deferred)
- freezed reconsidered if the project grows beyond ~3000 LOC
- Riverpod migration if Provider limitations are encountered

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented
- Use implementation patterns consistently across all components
- Respect project structure and layer boundaries
- Refer to this document for all architectural questions
- When in doubt about a pattern, check the existing code for examples before inventing new ones

**First Implementation Priority:**
1. Add `get_it` + `mocktail` to pubspec.yaml
2. Create `core/domain/` directory structure with enums, Result, ViewState
3. Extract pure enums from `enums.dart`
4. Create Repository interfaces


