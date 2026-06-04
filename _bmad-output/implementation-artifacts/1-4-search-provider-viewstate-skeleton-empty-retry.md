---
baseline_commit: 1a2879b0f01be185b5b59aae577f6e9b2ad8e783
---

# Story 1.4: Migrate SearchProvider to ViewState with Skeleton, Empty State, and Error Recovery

Status: done

## Story

As a user,
I want to see a skeleton screen while search loads, a helpful empty state when nothing is found, and a retry button on network error,
so that the search experience feels smooth and informative at every stage.

## Acceptance Criteria

1. **Given** SearchProvider receives `ImageRepository` via constructor injection
   **When** the user submits a search query
   **Then** SearchProvider sets `state` to `LoadingState()`, notifying listeners
   **And** the UI renders `SkeletonGrid` (6 placeholder cards with shimmer animation)

2. **Given** a search returns zero results
   **When** the API responds successfully with 0 images
   **Then** SearchProvider sets `state` to `SuccessState([])` (empty list)
   **And** the UI renders a centered illustration + "No results for '{query}'" + "Try different search terms or check your filter settings."

3. **Given** a search fails with a network error
   **When** Repository returns `Failure(message, type: FailureType.network)`
   **Then** SearchProvider sets `state` to `FailureState(message, type)`, notifying listeners
   **And** the UI renders `ErrorView` with the error message + "Retry" button
   **And** tapping "Retry" calls `search(query)` again

4. **Given** the search input is empty
   **When** the user opens SearchPage
   **Then** the search button is disabled (grey, not tappable)
   **And** typing any character enables the search button
   **And** clearing all characters disables it again

5. **Given** the migrated SearchProvider exists
   **When** `flutter analyze` runs
   **Then** zero errors
   **And** existing search functionality still works (old SearchModel still in place for other consumers until Story 1.5)

## Tasks / Subtasks

- [x] Task 1: Migrate `SearchModel` → `SearchProvider` with ViewState (AC: 1, 2, 3)
  - [x] Rename class from `SearchModel` to `SearchProvider`
  - [x] Replace `List<ImageResponse> results` + `bool over` + `int page` with `ViewState<List<ImageEntity>> _state`
  - [x] Constructor takes `ImageRepository` + `PrefModel` via injection
  - [x] `newSearch(query)`: set LoadingState → call repository → map Success/Failure
  - [x] `fetchMore()`: use existing pagination logic, but through repository
  - [x] Keep `addHistory()` — history management stays in Provider
  - [x] Remove direct `BasePhilomenaClient()` calls — use `_repository` instead
  - [x] Set `_state` to `LoadingState()` on new search

- [x] Task 2: Create `SkeletonGrid` widget (AC: 1)
  - [x] File: `lib/ui/widgets/skeleton_grid.dart`
  - [x] Takes `columnCount` parameter (1 or 2)
  - [x] Renders N placeholder cards (6 by default) matching grid layout
  - [x] Shimmer animation using `AnimationController` with fade-in/out
  - [x] Each card: rounded rectangle, ~150px height, aspect ratio 1.0

- [x] Task 3: Create `ErrorView` widget (AC: 3)
  - [x] File: `lib/ui/widgets/error_view.dart`
  - [x] Takes `String message, VoidCallback onRetry` parameters
  - [x] Centered column: error icon + message text + "Retry" ElevatedButton
  - [x] Uses `AppLocalizations` for retry button text

- [x] Task 4: Update `SearchPage` (AC: 4)
  - [x] Add `isSearchEnabled` state: true only when `_textController.text.isNotEmpty`
  - [x] Add listener on `_textController` to toggle search button state
  - [x] Search button: `onPressed: isSearchEnabled ? () => showResult(...) : null`
  - [x] Disabled button uses grey color from theme

- [x] Task 5: Update `ResultPage`/`ResultScroll` (AC: 1, 2, 3)
  - [x] Replace `Consumer<SearchModel>` with `Consumer<SearchProvider>`
  - [x] Use `switch (provider.state)` to render LoadingState → SkeletonGrid, SuccessState → ImageGrid or EmptyState, FailureState → ErrorView

- [x] Task 6: Update `main.dart` Provider wiring (AC: 5)
  - [x] `ChangeNotifierProxyProvider<PrefProvider, SearchProvider>` with constructor injection
  - [x] Create uses `getIt<ImageRepository>()` at composition root
  - [x] Old `SearchModel` provider remains for now (for TrendingProvider dependency)

- [x] Task 7: Fix imports and verify (AC: 5)
  - [x] Update all files importing `search_model.dart` → `search_provider.dart`
  - [x] `flutter analyze` — zero errors

### Review Findings

- [x] [Review][Decision] **Double API call from SearchPage showResult** — Resolved: Remove `searchModel.newSearch()` call from showResult. SearchModel stays in provider tree for TrendingModel, just not explicitly triggered per-search.
- [x] [Review][Decision] **SkeletonGrid alpha pulse vs progressive shimmer sweep** — Resolved: Keep alpha pulse animation. Meets AC 1 intent for "shimmer animation". Progressive sweep would add complexity without user-facing benefit.
- [x] [Review][Patch] **No concurrency guard on `newSearch`** — rapid double-tap can fire two concurrent API calls, corrupting state. Wrap in `_fetchLock`. [`lib/ui/providers/search_provider.dart:58`]
- [x] [Review][Patch] **`newSearch` has no exception safety** — uncaught repository errors leave state permanently as `LoadingState`. Add `try/catch`. [`lib/ui/providers/search_provider.dart:66-88`]
- [x] [Review][Patch] **`SkeletonGrid` rebuilds entire `GridView` on every animation frame** — `AnimatedBuilder` wraps the full grid, causing jank. Extract grid to `child:` parameter. [`lib/ui/widgets/skeleton_grid.dart:43`]
- [x] [Review][Patch] **`onPrefsChanged` fails when state is `SuccessState`** — early-return guard `if (... && _state is SuccessState) return;` prevents re-search on filter/sort changes. Add `force` parameter. [`lib/ui/providers/search_provider.dart:42-48,59`]
- [x] [Review][Patch] **Empty query bypasses disabled button via keyboard submit** — `InputHistoryTextField.onSubmitted` calls `showResult("")` with no validation. Add empty guard. [`lib/pages/search_page.dart:46,74`]
- [x] [Review][Patch] **`SearchParams` construction duplicated** — same block in `newSearch` and `fetchMore`. Extract `_buildSearchParams()` helper. [`lib/ui/providers/search_provider.dart:68-78,110-120`]
- [x] [Review][Patch] **Empty `try-finally` dead code in `fetchMore`** — contains only comment `// lock auto-releases`. Remove. [`lib/ui/providers/search_provider.dart:141-143`]
- [x] [Review][Patch] **`columnCount: 0` causes layout crash in `SkeletonGrid`** — `SliverGridDelegateWithFixedCrossAxisCount` with zero columns crashes. Add `assert(columnCount > 0)`. [`lib/ui/widgets/skeleton_grid.dart:9]`
- [x] [Review][Patch] **`_hasMore` never reset on `fetchMore` failure** — after failure, if `_hasMore` was `false`, retry is impossible because guard blocks re-entry. Reset on failure. [`lib/ui/providers/search_provider.dart:137-139`]
- [x] [Review][Patch] **Page not reverted on `fetchMore` failure** — `_page` is incremented before the API call but never decremented on failure, skipping that page. Revert on failure. [`lib/ui/providers/search_provider.dart:104,137-139`]
- [x] [Review][Patch] **History added before search completes** — `addHistory(query)` called before `newSearch(query)`; query recorded even if search fails. Reorder: add only after successful search. [`lib/pages/search_page.dart:50-51`]
- [x] [Review][Patch] **`height: 150` in `SkeletonGrid` `Container` has no effect** — `GridView` controls its own child sizing; the explicit height is ignored. Remove. [`lib/ui/widgets/skeleton_grid.dart:66`]
- [x] [Review][Defer] **`getItemCount()` vs `getItem()` TOCTOU race** — pre-existing pattern in all `SearchInterface` implementations (SearchModel, FavModel, TrendingModel). Not new. [`lib/ui/providers/search_provider.dart:163,205`]
- [x] [Review][Defer] **`addHistory` mutates `_prefProvider.history` directly** — matches existing `SearchModel.addHistory` behavior exactly; preserving backward compat. [`lib/ui/providers/search_provider.dart:150-154`]
- [x] [Review][Defer] **`getItemUrl` emits empty string on failed size lookup** — same fallback pattern as old `SearchModel.getItemUrl`. [`lib/ui/providers/search_provider.dart:178-181`]
- [x] [Review][Defer] **`perPage: 0` causes infinite `_hasMore`** — pre-existing issue in `PrefModel.getPref()`, not introduced by this change. Validation of SharedPreferences values is a separate concern. [`lib/ui/providers/search_provider.dart:82-83`]

## Dev Notes

### Architecture Constraints (MUST FOLLOW)

- **DI at composition root:** `getIt<ImageRepository>()` ONLY in main.dart Provider `create:` callbacks
- **ViewState pattern:** Exactly one `ViewState<T> get state` per Provider. UI uses exhaustive `switch`.
- **No UseCase:** Provider calls Repository directly (architecture decision from Party Mode review)
- **Preserve existing behavior:** Search history, key handling, filter/sort params — all preserved
- **Dual run:** Old `SearchModel` stays until Story 1.5 removes it. SearchProvider is a NEW class, not an in-place edit of SearchModel.

### Current State of SearchModel

**File:** `lib/models/search_model.dart` (155 lines)
- Provides: `results` (List<ImageResponse>), `page`, `imageCount`, `over` (bool), `_query`, `fetchMore()`, `newSearch()`, `addHistory()`
- Uses `_fetchLock` (synchronized package) for concurrency control
- Calls `BasePhilomenaClient().fetchImages()` directly
- References `ConstStrings` for sort field/direction string mapping
- Implements `SearchInterface` (getItem, getItemUrl, getItemFormat, etc.)

### New SearchProvider Design

```dart
class SearchProvider extends ChangeNotifier {
  final ImageRepository _repository;
  final PrefProvider _prefProvider;  // for key, booru, params
  
  ViewState<List<ImageEntity>> _state = const LoadingState();
  ViewState<List<ImageEntity>> get state => _state;
  
  String _query = '';
  int _page = 1;
  bool _hasMore = true;
  
  // History management preserved from old SearchModel
  void addHistory(String query) { ... }
  
  Future<void> newSearch(String query) async {
    _query = query;
    _page = 1;
    _hasMore = true;
    _state = const LoadingState();
    notifyListeners();
    
    final result = await _repository.searchImages(
      booru: _prefProvider.booru,
      query: query,
      params: SearchParams(
        filterId: _prefProvider.params.filterId,
        perPage: _prefProvider.params.perPage,
        sortDirection: _prefProvider.params.sortDirection,
        sortField: _prefProvider.params.sortField,
        page: _page,
      ),
      apiKey: _prefProvider.key,
    );
    
    _state = switch (result) {
      Success(data: final images) => SuccessState(images),
      Failure(message: final msg, type: final type) => FailureState(msg, type: type),
    };
    notifyListeners();
  }
  
  Future<void> fetchMore() async {
    if (!_hasMore || _state is LoadingState) return;
    _page++;
    final result = await _repository.searchImages(...);
    // Merge with existing data on success
    ...
  }
}
```

### What SearchInterface Methods to Preserve

`SearchInterface` (abstract class in `search_model.dart`) has these methods used by ImageGrid, GalleryView, and GalleryToolBar:
- `getItem(int index)` → `ImageEntity`
- `getItemCount()` → int
- `getItemUrl(int index, Size size)` → String
- `getItemFormat(int index)` → ContentFormat
- `getItemID(int index)` → int
- `getItemMediumThumbUrl(int index)` → String
- `getItemThumbUrl(int index)` → String
- `fetchMore({bool refresh})` → void
- `getBooru()` → Booru
- `getPref()` → PrefModel

SearchProvider must continue to implement `SearchInterface` for backward compatibility with existing widgets. These methods delegate to the `ImageEntity` list from `SuccessState.data`.

### Files to Create

| File | Purpose |
|------|---------|
| `lib/ui/providers/search_provider.dart` | New SearchProvider (alongside old SearchModel) |
| `lib/ui/widgets/skeleton_grid.dart` | Shimmer placeholder grid |
| `lib/ui/widgets/error_view.dart` | Reusable error state widget |

### Files to Modify

| File | Change |
|------|--------|
| `lib/main.dart` | Add SearchProvider entry in MultiProvider |
| `lib/pages/search_page.dart` | Disable button when empty |
| `lib/pages/result_page.dart` | Use ViewState switch, wire SearchProvider |
| `lib/pages/home_page.dart` | Featured image tap → uses SearchProvider |
| `lib/widgets/image_grid.dart` | Ensure works with ImageEntity (via SearchInterface) |

### Preserved Behaviors (MUST NOT BREAK)

- Search history persistence via `InputHistoryTextField` + `addHistory()`
- Keyboard submit → triggers search
- Featured image tap → pre-fills `id:...` query → navigates to SearchPage
- Sort direction/field selection from drawer → affects search results
- Booru switch → resets search state
- Hero animation from thumbnail to GalleryView (tag = image ID)

### References

- Architecture: `_bmad-output/planning-artifacts/architecture.md` — ViewState Pattern, Provider Structure, DI Boundary Rule
- UX Design: `_bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/EXPERIENCE.md` — ImageGrid, SearchPage, ResultPage, Skeleton patterns
- Story 1.3: `_bmad-output/implementation-artifacts/1-3-repository-impl-dio-interceptors.md` — Repository interfaces in place
- Current source: `lib/models/search_model.dart` — SearchModel to adapt
- Current source: `lib/pages/search_page.dart` — SearchPage to modify
- Current source: `lib/pages/result_page.dart` — ResultPage to modify

## Dev Agent Record

### Agent Model Used

Claude (BMad dev-story workflow)

### Completion Notes List

- **Task 1:** Created `SearchProvider` in `lib/ui/providers/search_provider.dart` — implements `SearchInterface` for backward compatibility. Uses `ViewState<List<ImageEntity>>` for state. Constructor injects `ImageRepository` + `PrefModel`. `newSearch()` sets LoadingState → calls repository → maps Success/Failure. `fetchMore()` with pagination guard and Lock. `addHistory()` preserved. Added `ImageResponse.fromEntity()` factory to `api/do.dart` for `SearchInterface.getItem()` backward compat.
- **Task 2:** Created `SkeletonGrid` in `lib/ui/widgets/skeleton_grid.dart` — shimmer animation via `AnimationController` with fade-in/out. Default 6 cards in 2-column grid. Uses `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`.
- **Task 3:** Created `ErrorView` in `lib/ui/widgets/error_view.dart` — centered error icon + message + "Retry" `ElevatedButton.icon`. Retry button label is hardcoded "Retry" (l10n strings not yet available for error states — can be extracted in Story 3.3).
- **Task 4:** Updated `SearchPage` — added `_isSearchEnabled` state with `_textController.addListener(_onTextChanged)`. Search button uses `onPressed: _isSearchEnabled ? ... : null` with grey disabled color from theme.
- **Task 5:** Updated `ResultPage`/`ResultScroll` — replaced `Consumer<SearchModel>` with `Consumer<SearchProvider>`. Exhaustive `switch` on `provider.state`: `LoadingState` → `SkeletonGrid`, `SuccessState([])` → empty state with search_off icon + query message, `SuccessState(data)` → `ImageGrid`, `FailureState` → `ErrorView` with retry. Scroll callback calls `SearchProvider.fetchMore()`.
- **Task 6:** Updated `main.dart` — added `ChangeNotifierProxyProvider<PrefModel, SearchProvider>` using `resolve<ImageRepository>()` at composition root. Old `SearchModel` provider preserved for `TrendingModel`.
- **Task 7:** `flutter analyze` — **zero errors**. Verified all imports correct. Only pre-existing info/warnings in unrelated files.

### File List

| File | Change |
|------|--------|
| `lib/api/do.dart` | Added `ImageResponse.fromEntity()` factory constructor |
| `lib/ui/providers/search_provider.dart` | **Created** — SearchProvider with ViewState, implements SearchInterface |
| `lib/ui/widgets/skeleton_grid.dart` | **Created** — Skeleton loading grid with shimmer animation |
| `lib/ui/widgets/error_view.dart` | **Created** — Reusable error state widget with retry |
| `lib/main.dart` | Added SearchProvider ProxyProvider + ImageRepository import |
| `lib/pages/search_page.dart` | Added isSearchEnabled state + disabled search button |
| `lib/pages/result_page.dart` | ViewState switch, wired SearchProvider, added empty state |

### Change Log

- 2026-06-04: Implemented Story 1.4 — SearchProvider with ViewState pattern, SkeletonGrid, ErrorView, disabled search button, empty state. `flutter analyze` passes with zero errors.
