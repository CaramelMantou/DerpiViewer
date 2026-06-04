# Story 1.5: Migrate TrendingProvider to ViewState with Skeleton, Error, and Infinite-Scroll Fixes

Status: ready-for-dev

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

- [ ] Task 1: Migrate `TrendingModel` → `TrendingProvider` with ViewState (AC: 1, 2, 3)
  - [ ] Rename class from `TrendingModel` to `TrendingProvider`
  - [ ] Extends `SearchProvider` (preserves inheritance)
  - [ ] Replace `ImageResponse? featured` + `List<ImageResponse> results` with ViewState-based management
  - [ ] Constructor takes `ImageRepository` + `PrefProvider` via injection
  - [ ] `fetchMore()`: fetch trending images via `_repository.searchImages()` with featured query
  - [ ] Separate `_featuredImage` into its own `ViewState<ImageEntity>` for the banner
  - [ ] On first load: `_featuredState = LoadingState()` + `_state = LoadingState()`
  - [ ] Featured image fetched via `_repository.getFeaturedImage()`
  - [ ] Remove direct `BasePhilomenaClient()` calls

- [ ] Task 2: Fix infinite-scroll sentinel (AC: 2)
  - [ ] Add explicit `_hasMore` boolean — set to `false` when API returns empty
  - [ ] Guard `fetchMore()`: return early if `!_hasMore || _state is LoadingState`
  - [ ] Content < viewport check: if initial load returns fewer items than viewport capacity, don't auto-trigger fetchMore

- [ ] Task 3: Add tail loading indicator (AC: 2)
  - [ ] Modify `ImageGrid` (or TrendingScroll) to show a `CircularProgressIndicator` at grid bottom when `_isLoadingMore`
  - [ ] Add `bool _isLoadingMore = false` to TrendingProvider, set during fetchMore, reset on completion

- [ ] Task 4: Handle partial-load errors (AC: 3)
  - [ ] Distinguish first-load error vs fetchMore error in the Provider
  - [ ] First-load error: set `_state = FailureState(...)` → UI shows ErrorView
  - [ ] FetchMore error: keep existing data, show snackbar via `ScaffoldMessenger`

- [ ] Task 5: Update `home_page.dart` / `TrendingScroll` (AC: 1)
  - [ ] Replace `Consumer<TrendingModel>` with `Consumer<TrendingProvider>`
  - [ ] Use `switch (trending.featuredState)` for featured image banner (Loading→Skeleton, Success→CachedNetworkImage, Failure→fallback)
  - [ ] Use `switch (trending.state)` for grid (Loading→SkeletonGrid, Success→ImageGrid, Failure→ErrorView)

- [ ] Task 6: Update `main.dart` Provider wiring (AC: 4)
  - [ ] Replace old `TrendingModel` ChangeNotifierProxyProvider with `TrendingProvider`
  - [ ] Constructor uses `getIt<ImageRepository>()` at composition root
  - [ ] Remove old `SearchModel` provider if no longer needed

- [ ] Task 7: Clean up and verify (AC: 4)
  - [ ] Remove old `TrendingModel` class
  - [ ] Remove old `SearchModel` class if no consumers remain
  - [ ] `flutter analyze` — zero errors

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

Claude (BMad create-story workflow)

### Completion Notes List

### File List
