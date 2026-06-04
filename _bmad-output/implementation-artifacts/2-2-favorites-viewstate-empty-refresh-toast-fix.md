---
baseline_commit: e13a237690a063fdd141ef07ae8c842419b17e52
---
# Story 2.2: Migrate FavoritesProvider to ViewState with Empty State, Refresh, and Toast Fix

Status: done

## Story

As a user,
I want to see a helpful empty state when I have no favorites, see up-to-date data when I return to favorites, and get accurate toast confirmations,
so that managing my favorites collection is reliable and intuitive.

## Acceptance Criteria

1. **Given** FavoritesProvider receives `FavoritesRepository` via constructor injection
   **When** the user navigates to FavouritePage with zero favorites
   **Then** Provider sets `state` to `SuccessState([])` (empty list)
   **And** the UI renders a centered heart-outline illustration + "No favorites yet" + "Tap the heart icon on any image in the gallery to save it here."

2. **Given** the user has favorited images
   **When** they unfavorite an image in GalleryView and navigate back to FavouritePage
   **Then** FavouritePage triggers `fetchMore(refresh: true)` when it regains visibility
   **And** the unfavorited image no longer appears in the grid

3. **Given** the user taps the favorite icon in the GalleryToolbar
   **When** the toggle action is triggered
   **Then** the toast message fires AFTER the DB write completes successfully — not before
   **And** if faved: toast shows "Added to favorites" after DB INSERT succeeds
   **And** if unfaved: toast shows "Removed from favorites" after DB DELETE succeeds
   **And** if the DB operation fails: toast shows "Failed to update favorite"

4. **Given** the user rapidly toggles the favorite icon
   **When** multiple taps fire in quick succession
   **Then** a lock/mutex prevents concurrent DB writes
   **And** only the final intended state is persisted

5. **Given** `flutter analyze` runs
   **Then** zero errors

## Tasks / Subtasks

- [x] Task 1: Migrate `FavModel` → `FavoritesProvider` with ViewState (AC: 1)
  - [x] Rename class from `FavModel` to `FavoritesProvider`
  - [x] Replace `List<ImageResponse> results` + `int page` + `bool over` with `ViewState<List<ImageEntity>> _state`
  - [x] Constructor takes `FavoritesRepository` via injection
  - [x] `fetchMore(refresh:)`: call `_repository.getFavorites()`, map to ViewState
  - [x] Remove direct `DbHelper.getFavorites()` call
  - [x] Implements `SearchInterface` for ImageGrid compatibility

- [x] Task 2: Add empty state UI (AC: 1)
  - [x] In `FavouritePage`: switch on `provider.state`
  - [x] LoadingState → `SkeletonGrid` (reuse from Story 1.4)
  - [x] SuccessState with empty list → centered heart-outline icon + text
  - [x] SuccessState with data → `FavouriteScroll` > `ImageGrid`
  - [x] FailureState → `ErrorView` (reuse from Story 1.4)

- [x] Task 3: Add refresh on visibility (AC: 2)
  - [x] In FavouritePage, add `WidgetsBindingObserver` mixin
  - [x] On `didChangeAppLifecycleState` resumed: call `provider.fetchMore(refresh: true)`

- [x] Task 4: Fix toast timing (AC: 3)
  - [x] In GalleryToolbar's favorite toggle handler: moved toast AFTER `await DbHelper.putFavorite(...)` completes
  - [x] Show success toast only after DB write succeeds
  - [x] Show error toast "Failed to update favorite" on exception

- [x] Task 5: Add rapid-toggle protection (AC: 4)
  - [x] Used `synchronized` package `Lock` (`_toggleLock`) to prevent concurrent DB writes
  - [x] Async handler wrapped in `_toggleLock.synchronized()` — only one toggle proceeds at a time

- [x] Task 6: Update main.dart wiring (AC: 5)
  - [x] Replaced old `FavModel` ChangeNotifierProxyProvider with `FavoritesProvider`
  - [x] Constructor uses `resolve<FavoritesRepository>()`
  - [x] Updated `home_page.dart` reference from `FavModel` to `FavoritesProvider`
  - [x] Deleted `lib/models/fav_model.dart` (replaced)

### Review Findings

- [x] [Review][Decision] AC 2 visibility refresh — toolbar now calls `(model as FavoritesProvider).changeFav()` after successful DB write, keeping favorites list in sync when returning from gallery [lib/widgets/toolbar.dart:75-78]
- [x] [Review][Patch] Decision resolved via option 2 (direct Provider notification)

## Dev Notes

### Architecture Constraints

- **DI at composition root:** `getIt<FavoritesRepository>()` ONLY in main.dart
- **ViewState pattern:** One `ViewState<List<ImageEntity>>` per Provider
- **Toast AFTER DB:** Critical UX fix — current code toasts BEFORE the async DB write

### Current State of FavModel

**File:** `lib/models/fav_model.dart` (128 lines)
- Extends `SearchInterface` directly (does NOT extend SearchModel)
- Calls `DbHelper.getFavorites()` (static) for data
- Has `_isLocked` boolean for concurrency (weak — doesn't prevent all races)
- `changeFav()` triggers `_fetchResult(refresh: true)` + `notifyListeners()`

### Toast Fix Detail

Current code in GalleryToolbar:
```dart
onTap: () {
  favController.toggleFav();  // UI toggles immediately
  Fluttertoast.showToast(msg: "...");  // Toast fires BEFORE DB write
  DbHelper.putFavorite(...);  // DB write is fire-and-forget
}
```

Fixed code:
```dart
onTap: () async {
  if (_isToggling) return;
  _isToggling = true;
  try {
    final newState = !favController.value;
    await DbHelper.putFavorite(model.getBooru(), model.getItem(index), newState);
    favController.value = newState;
    Fluttertoast.showToast(msg: newState ? "Added to favorites" : "Removed from favorites");
  } catch (e) {
    Fluttertoast.showToast(msg: "Failed to update favorite");
  } finally {
    _isToggling = false;
  }
}
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/ui/providers/favorites_provider.dart` | New FavoritesProvider |

### Files to Modify

| File | Change |
|------|--------|
| `lib/pages/fav_page.dart` | Wire FavoritesProvider, add ViewState switch + empty state |
| `lib/ui/widgets/gallery_toolbar.dart` | Fix toast timing + add rapid-toggle guard |
| `lib/main.dart` | Replace FavModel provider with FavoritesProvider |
| `lib/models/fav_model.dart` | Delete (replaced) |

### Preserved Behaviors (MUST NOT BREAK)

- Favorites page accessible from FAB
- Thumbnail → GalleryView navigation from favorites grid
- Booru switch → favorites reload
- Favorite icon state persistence across gallery page changes
- SearchInterface methods (getItem, getItemUrl, etc.)

### References

- UX Design: EXPERIENCE.md — Flow 3: Favorites Management, Empty State guidance
- UX Design: UX-DR3, UX-DR9, UX-DR18
- Story 1.4: SkeletonGrid + ErrorView already created
- Current source: `lib/models/fav_model.dart`
- Current source: `lib/pages/fav_page.dart`
- Current source: `lib/widgets/toolbar.dart`

## Dev Agent Record

### Agent Model Used

Claude (BMad dev-story workflow)

### Debug Log

- **T1 FavoritesProvider:** Created `lib/ui/providers/favorites_provider.dart` with ViewState pattern. Extends `ChangeNotifier`, implements `SearchInterface`. Uses `FavoritesRepository` via DI, `Lock` from synchronized package for concurrency. `changeFav()` triggers `_fetchResult(refresh: true)`.
- **T2 Empty state:** Added switch on `provider.state` in `FavouritePage._buildBody()`: LoadingState→SkeletonGrid, SuccessState([])→empty state UI (heart_outline icon + text), SuccessState with data→FavouriteScroll, FailureState→ErrorView with retry.
- **T3 Visibility refresh:** Added `WidgetsBindingObserver` mixin to `_FavouritePageState`. On `didChangeAppLifecycleState` resumed, calls `_refreshFavorites()` which does `provider.fetchMore(refresh: true)`.
- **T4 Toast timing:** Rewrote favorite toggle onTap handler to use `async`/`await`. Toast fires AFTER `DbHelper.putFavorite()` completes. Success toast for added/removed. Error toast "Failed to update favorite" on exception.
- **T5 Rapid-toggle protection:** Added `_toggleLock = Lock()` to GalleryToolBar. Entire toggle handler wrapped in `_toggleLock.synchronized()` to prevent concurrent DB writes.
- **T6 Wiring:** Updated `main.dart` to use `FavoritesProvider(resolve<FavoritesRepository>(), ...)`. Updated `home_page.dart` import and `Provider.of<FavoritesProvider>`. Deleted `lib/models/fav_model.dart`.

### Completion Notes List

- Implemented all 5 Acceptance Criteria for Story 2.2
- Created FavoritesProvider with ViewState pattern matching SearchProvider/TrendingProvider architecture
- Empty state: heart_outline icon (80px) + "No favorites yet" + descriptive guidance text
- Visibility refresh: WidgetsBindingObserver detects app resume → refreshes favorites
- Toast timing fixed: toast now fires AFTER async DB write completes, with success/error feedback
- Rapid-toggle protection: synchronized Lock prevents concurrent DB writes
- DI wiring: FavoritesRepository injected via getIt at composition root (main.dart)
- flutter analyze: 0 errors; 80/80 tests passing with 0 regressions
- 1 file created, 4 files modified, 1 file deleted

### File List

- `lib/ui/providers/favorites_provider.dart` — created (FavoritesProvider with ViewState + SearchInterface)
- `lib/pages/fav_page.dart` — modified (ViewState switch, empty state UI, WidgetsBindingObserver)
- `lib/widgets/toolbar.dart` — modified (async toast timing, synchronized lock for rapid-toggle)
- `lib/main.dart` — modified (FavoritesProvider with DI instead of FavModel)
- `lib/pages/home_page.dart` — modified (FavModel → FavoritesProvider import)
- `lib/models/fav_model.dart` — deleted (replaced by FavoritesProvider)

## Change Log

- 2026-06-04: Story 2.2 implemented — FavoritesProvider with ViewState, empty state UI, visibility refresh, toast timing fix, rapid-toggle protection (Agent: Claude via BMad dev-story)
