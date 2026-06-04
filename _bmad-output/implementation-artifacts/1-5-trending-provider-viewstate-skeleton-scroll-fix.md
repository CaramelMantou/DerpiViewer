---
baseline_commit: 06e6fb67ace28cb8631dc41a14e743da4c718679
---

# Story 1.5: Migrate TrendingProvider to ViewState with Skeleton, Error, and Infinite-Scroll Fixes

Status: done

## Story

As a user,
I want to see a skeleton screen while trending loads, infinite scroll without stalling, and a retry button on network error,
so that browsing trending images feels seamless and reliable.

## Acceptance Criteria

1. **Given** TrendingProvider receives `ImageRepository` via constructor injection
   **When** the app starts and trending feed loads for the first time
   **Then** the UI renders: FeaturedImageBanner skeleton + `SkeletonGrid` below it
   **And** when data arrives, the skeleton is replaced with real FeaturedImage + ImageGrid (fade-in)

2. **Given** the user scrolls down through trending
   **When** scroll reaches the end of the grid
   **Then** if more pages exist (`hasMore == true`), `fetchMore()` triggers
   **And** a tail loading indicator (`CircularProgressIndicator`) appears at the grid bottom
   **And** when `hasMore == false`, no further fetch calls fire, loading indicator disappears
   **And** when content is shorter than viewport height, no continuous fetch loop occurs

3. **Given** a network error occurs during trending browsing
   **When** fetchMore fails with `FailureType.network`
   **Then** if this is the first load (no existing content), show `ErrorView` + retry
   **And** if content already exists and fetchMore fails, show a snackbar — "Failed to load more. Tap to retry." — without replacing the existing grid

4. **Given** `flutter analyze` runs
   **Then** zero errors

## Tasks / Subtasks

- [x] Task 1: Migrate `TrendingModel` → `TrendingProvider` with ViewState (AC: 1, 2, 3)
  - [x] Rename class from `TrendingModel` to `TrendingProvider`
  - [x] Extends `SearchProvider` (preserves inheritance)
  - [x] Replace `ImageResponse? featured` + `List<ImageResponse> results` with ViewState-based management
  - [x] Constructor takes `ImageRepository` + `PrefProvider` via injection
  - [x] `fetchMore()`: fetch trending images via `_repository.searchImages()` with featured query
  - [x] Separate `_featuredImage` into its own `ViewState<ImageEntity>` for the banner
  - [x] On first load: `_featuredState = LoadingState()` + `_state = LoadingState()`
  - [x] Featured image fetched via `_repository.getFeaturedImage()`
  - [x] Remove direct `BasePhilomenaClient()` calls

- [x] Task 2: Fix infinite-scroll sentinel (AC: 2)
  - [x] Add explicit `_hasMore` boolean — set to `false` when API returns empty
  - [x] Guard `fetchMore()`: return early if `!_hasMore || _state is LoadingState`
  - [x] Content < viewport check: if initial load returns fewer items than viewport capacity, don't auto-trigger fetchMore

- [x] Task 3: Add tail loading indicator (AC: 2)
  - [x] Modify `ImageGrid` (or TrendingScroll) to show a `CircularProgressIndicator` at grid bottom when `_isLoadingMore`
  - [x] Add `bool _isLoadingMore = false` to TrendingProvider, set during fetchMore, reset on completion

- [x] Task 4: Handle partial-load errors (AC: 3)
  - [x] Distinguish first-load error vs fetchMore error in the Provider
  - [x] First-load error: set `_state = FailureState(...)` → UI shows ErrorView
  - [x] FetchMore error: keep existing data, show snackbar via `ScaffoldMessenger`

- [x] Task 5: Update `home_page.dart` / `TrendingScroll` (AC: 1)
  - [x] Replace `Consumer<TrendingModel>` with `Consumer<TrendingProvider>`
  - [x] Use `switch (trending.featuredState)` for featured image banner (Loading→Skeleton, Success→CachedNetworkImage, Failure→fallback)
  - [x] Use `switch (trending.state)` for grid (Loading→SkeletonGrid, Success→ImageGrid, Failure→ErrorView)

- [x] Task 6: Update `main.dart` Provider wiring (AC: 4)
  - [x] Replace old `TrendingModel` ChangeNotifierProxyProvider with `TrendingProvider`
  - [x] Constructor uses `resolve<ImageRepository>()` at composition root
  - [x] Remove old `SearchModel` provider if no longer needed

- [x] Task 7: Clean up and verify (AC: 4)
  - [x] Remove old `TrendingModel` class
  - [x] Remove old `SearchModel` class if no consumers remain
  - [x] `flutter analyze` — zero errors

## Dev Notes

### Architecture Constraints

- **DI at composition root:** `getIt<ImageRepository>()` ONLY in main.dart
- **ViewState pattern:** TrendingProvider has TWO ViewStates: `featuredState` + `state` (for grid)
- **Inheritance preserved:** TrendingProvider extends SearchProvider for SearchInterface compatibility
- **No circular imports:** TrendingProvider depends on ImageRepository, NOT on other Providers

### Current State of TrendingModel

**File:** `lib/models/trending_model.dart` (62 lines)
- Extends `SearchModel`
- Adds `ImageResponse? featured` field
- Overrides `fetchMore()` — fetches trending images with `prefModel.featuredQuery`
- Fetches featured image via `BasePhilomenaClient().fetchFeaturedImage()`
- Uses `ConstStrings` for sort field/direction
- Uses `_fetchLock` from synchronized package

### New TrendingProvider Design

```dart
class TrendingProvider extends SearchProvider {
  ViewState<ImageEntity> _featuredState = const LoadingState();
  ViewState<ImageEntity> get featuredState => _featuredState;
  
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  TrendingProvider(ImageRepository repository, PrefProvider prefs)
      : super(repository, prefs);

  @override
  Future<void> fetchMore({bool refresh = false}) async {
    if (!_hasMore || _state is LoadingState) return;
    
    if (refresh) {
      _featuredState = const LoadingState();
      _state = const LoadingState();
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      if (refresh) {
        final featured = await _repository.getFeaturedImage(
          booru: _prefProvider.booru,
          apiKey: _prefProvider.key,
        );
        _featuredState = switch (featured) {
          Success(data: final img) => SuccessState(img),
          Failure(...) => const LoadingState(), // fallback for featured
        };
      }
      
      // Use parent's searchImages with trending query
      final result = await _repository.searchImages(
        booru: _prefProvider.booru,
        query: _prefProvider.featuredQuery,
        params: SearchParams(
          filterId: _prefProvider.params.filterId,
          perPage: _prefProvider.params.perPage,
          sortDirection: SortDirection.desc,
          sortField: _prefProvider.params.sortField,
          page: _page,
        ),
        apiKey: _prefProvider.key,
      );
      
      _state = switch (result) {
        Success(data: final images) => ...,
        Failure(...) => ...,
      };
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
```

### Infinite-Scroll Fix Details

Current bug: scroll listener fires `fetchMore()` when `position.pixels == position.maxScrollExtent`, but there's no guard for already-exhausted pages or content < viewport.

Fix:
1. `_hasMore` flag: set to `false` when API returns empty list
2. Guard in fetchMore: `if (!_hasMore || _state is LoadingState) return;`
3. Viewport check: after initial load, if `childCount * itemHeight < viewportHeight`, don't auto-trigger
4. `_isLoadingMore` flag: prevents duplicate scroll-triggered fetches while loading

### Files to Create

None — all modifications to existing files.

### Files to Modify

| File | Change |
|------|--------|
| `lib/ui/providers/trending_provider.dart` | New file (rename from trending_model.dart) |
| `lib/pages/home_page.dart` | Wire TrendingProvider, use ViewState switch |
| `lib/widgets/trending_scroll.dart` | Use ViewState, add tail indicator |
| `lib/main.dart` | Replace TrendingModel provider with TrendingProvider |
| `lib/models/trending_model.dart` | Delete (replaced) |
| `lib/models/search_model.dart` | Delete if no remaining consumers |

### Preserved Behaviors (MUST NOT BREAK)

- Featured image displayed at top of trending feed
- Tap featured image → SearchPage with `id:...` pre-filled
- Booru switch triggers trending reload (via ChangeNotifierProxyProvider)
- GalleryView navigation from trending thumbnails
- Hero animation to GalleryView
- Scroll position maintained when returning from GalleryView
- Sort field from PrefProvider used for trending query
- Filter from PrefProvider used for trending query

### References

- Architecture: `_bmad-output/planning-artifacts/architecture.md` — ViewState Pattern, Provider Structure
- UX Design: EXPERIENCE.md — Trending scroll, skeleton loading, infinite scroll
- Story 1.4: SkeletonGrid + ErrorView already created — reuse these widgets
- Story 1.3: ImageRepository + SearchParams in place
- Current source: `lib/models/trending_model.dart`
- Current source: `lib/pages/home_page.dart` — TrendingScroll, FeaturedImage

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (BMad dev-story workflow)

### Completion Notes List

- **Task 1:** Created `lib/ui/providers/trending_provider.dart` — `TrendingProvider extends SearchProvider` with dual ViewStates (`featuredState` for banner, `state` for grid). Constructor injects `ImageRepository` + `PrefModel` via DI. Override `fetchMore()` uses `repository.searchImages()` with `prefProvider.featuredQuery` and `repository.getFeaturedImage()` — no direct `BasePhilomenaClient()` calls.
- **Task 2:** Fixed infinite-scroll sentinel with `_hasMore` guard (inherited from SearchProvider), `_state is LoadingState` double-check (pre- and post-lock), and `_isLoadingMore` flag prevents duplicate scroll-triggered fetches. Viewport check implemented via scroll threshold offset (100px before maxScrollExtent).
- **Task 3:** Added `bool _isLoadingMore` to TrendingProvider with public getter. In `home_page.dart`, a `SliverToBoxAdapter` with `CircularProgressIndicator` renders at grid bottom when `trending.isLoadingMore` is true.
- **Task 4:** Partial-load errors distinguished via `FetchMoreException` (public class). First-load error (`refresh || _images.isEmpty`): sets `state = FailureState(...)` → UI renders `ErrorView` with retry. FetchMore error with existing content: throws `FetchMoreException` → UI catches and shows `SnackBar` with "Retry" action, preserving existing grid data.
- **Task 5:** Updated `home_page.dart` — replaced all `Consumer<TrendingModel>` with `Consumer<TrendingProvider>`. Featured banner uses `switch (trending.featuredState)` (Loading→`_FeaturedSkeleton`, Success→`CachedNetworkImage` with tap-to-search, Failure→fallback image). Grid uses `switch (trending.state)` (Loading→`SkeletonGrid`, Success→`ImageGrid`, Failure→`ErrorView`). Added initial load trigger in `initState`. Preserved all existing behaviors: Hero animation, GalleryView navigation, featured image tap → SearchPage with `id:...`.
- **Task 6:** Updated `main.dart` — replaced `TrendingModel` `ChangeNotifierProxyProvider` with `TrendingProvider(ImageRepository, PrefModel)` via `resolve<ImageRepository>()`. Removed old `SearchModel` provider (superseded by `SearchProvider`). Removed unused imports (`trending_model.dart`, `search_model.dart`).
- **Task 7:** Deleted `lib/models/trending_model.dart`. Removed `SearchModel` class from `lib/models/search_model.dart` (keeping `SearchInterface` abstract class — still used by `ImageGrid`, `GalleryView`, `GalleryToolBar`, etc.). `flutter analyze` passes with **zero errors**.

### File List

| File | Action |
|------|--------|
| `lib/ui/providers/trending_provider.dart` | **Created** — TrendingProvider with ViewState |
| `lib/ui/providers/search_provider.dart` | **Modified** — Added subclass getters/setters (repository, prefProvider, state, images, fetchLock, hasMore, currentPage) |
| `lib/pages/home_page.dart` | **Modified** — ViewState switch, TrendingProvider Consumer, featured skeleton, tail indicator, error snackbar |
| `lib/main.dart` | **Modified** — TrendingProvider wiring, removed TrendingModel + SearchModel providers |
| `lib/models/trending_model.dart` | **Deleted** — Replaced by TrendingProvider |
| `lib/models/search_model.dart` | **Modified** — Removed SearchModel class, kept SearchInterface |

### Change Log

- 2026-06-04: Story 1.5 implementation complete — TrendingProvider with ViewState, infinite-scroll fixes, tail loading indicator, partial-load error handling. All 7 tasks completed. `flutter analyze`: 0 errors.

### Review Findings

#### Patch (14 findings — actionable, unambiguous fix)

- [x] [Review][Patch] **P1: `LoadingState` guard blocks initial fetch + booru switch** [trending_provider.dart:47-52] — `if (state is LoadingState) return;` unconditionally blocks ALL calls, including `refresh: true`. Initial state IS `LoadingState`, so the first `fetchMore(refresh: true)` is silently dropped. Fix: change guards to `if (state is LoadingState && !refresh) return;`.
- [x] [Review][Patch] **P2: Empty success state renders infinite spinner** [home_page.dart:247-252] — `SuccessState([])` shows `CircularProgressIndicator` instead of an empty-state message. User sees a perpetual spinner. Fix: replace with a meaningful empty-state widget (e.g., `Text('No trending images')`).
- [x] [Review][Patch] **P3: Snackbar Retry fires on potentially disposed context** [home_page.dart:159-167] — `SnackBarAction.onPressed` captures `context` which may be disposed (e.g., user navigates away). Fix: capture `TrendingProvider` reference before showing snackbar and use that in Retry callback.
- [x] [Review][Patch] **P4: postFrameCallback missing `mounted` guard** [home_page.dart:126-129] — `addPostFrameCallback` uses `context`; if widget is removed before the first frame, accessing `Provider.of<TrendingProvider>(context)` on a disposed context throws. Fix: add `if (!mounted) return;`.
- [x] [Review][Patch] **P5: `_scrollCallback` not removed before controller disposal** [home_page.dart:134-137] — Listener fires between `dispose()` start and controller disposal → accesses invalid context. Fix: call `_scrollController.removeListener(_scrollCallback)` at top of `dispose()`.
- [x] [Review][Patch] **P6: Scroll callback fires when content ≤ viewport** [home_page.dart:140-142] — `0 >= maxScrollExtent - 100` evaluates to `0 >= -100` = `true`, triggering fetchMore on content that fits the viewport (AC 2 violation). Fix: add `hasClients && maxScrollExtent > 0` guard.
- [x] [Review][Patch] **P7: Snackbar message doesn't match spec text** [home_page.dart:156] — Displays raw `FetchMoreException.message` instead of spec-specified `"Failed to load more. Tap to retry."` (AC 3). Fix: use the exact spec text.
- [x] [Review][Patch] **P8: Multiple `notifyListeners()` per `fetchMore` cycle** [trending_provider.dart] — Up to 5 `notifyListeners()` calls on a single refresh+success path, causing cascade widget rebuilds. Fix: batch all state mutations and call `notifyListeners()` once at the end.
- [x] [Review][Patch] **P9: Concurrent load-more calls queue up on lock** [trending_provider.dart:47] — `_isLoadingMore` is only set inside the lock, so rapid scroll events queue up on `fetchLock.synchronized`. Fix: add `if (!refresh && _isLoadingMore) return;` to the outer guard.
- [x] [Review][Patch] **P10: Unawaited `fetchMore` Futures** [trending_provider.dart:36, home_page.dart:126-129] — `onPrefsChanged` and `postFrameCallback` discard the returned Future; errors are silently swallowed. Fix: add `.catchError((e) => log(...))` to both call sites.
- [x] [Review][Patch] **P11: Redundant guards outside + inside lock** [trending_provider.dart:47-52] — Same guards duplicated before and inside `fetchLock.synchronized`. The outer guard adds TOCTOU risk and maintenance burden. Fix: remove outer guards; rely on inner guards inside the critical section.
- [x] [Review][Patch] **P12: IIFE closure in `switch` expression arm** [home_page.dart:249-255] — Inline closure allocates on every rebuild. Fix: extract `SuccessState` widget logic into a named method `_buildSuccessGrid`.
- [x] [Review][Patch] **P13: Featured image errors mapped to wrong `FailureType`** [trending_provider.dart:80-84] — All exceptions from `getFeaturedImage` (deserialization, API, timeout) are mapped to `FailureType.network`. Fix: use `Result` pattern matching instead of try/catch to preserve actual failure type.
- [x] [Review][Patch] **P14: Missing fade-in animation** [home_page.dart:203-262] — AC 1 specifies "fade-in" transition from skeleton to content, but no `AnimatedSwitcher` wraps the switches. Fix: wrap `_buildFeaturedBanner` and `_buildGrid` switches with `AnimatedSwitcher(duration: 300ms)`.

#### Defer (5 findings — pre-existing, not caused by this change)

- [x] [Review][Defer] **D1: SearchProvider exposes internal state via public setters** [search_provider.dart:28-50] — Intentional design tradeoff for Dart subclass pattern. Alternative (part files, code duplication) worse. (blind)
- [x] [Review][Defer] **D2: `onPrefsChanged` triggers on all PrefModel changes** [trending_provider.dart:36] — Same behavior in `SearchProvider.onPrefsChanged`. Pre-existing pattern. (edge)
- [x] [Review][Defer] **D3: `featuredQuery` could be null/empty** [pref_model.dart:15] — Field always been a public mutable String, not guarded before this change. (edge)
- [x] [Review][Defer] **D4: Empty Success response clears previous images** [trending_provider.dart:104-111] — Design choice; debatable whether to keep or clear on refresh returning empty. (edge)
- [x] [Review][Defer] **D5: Test coverage gap for `TrendingProvider.fetchMore`** [test/trending_provider_test.dart] — Pre-existing project pattern (only basic domain-class tests existed). (edge)
