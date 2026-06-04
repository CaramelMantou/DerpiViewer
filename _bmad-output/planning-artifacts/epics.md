---
stepsCompleted: [1, 2, 3, 4]
workflowType: 'epics-and-stories'
lastStep: 4
status: 'complete'
completedAt: '2026-06-04'
inputDocuments:
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/EXPERIENCE.md
---

# derpiviewer - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for derpiviewer, decomposing the requirements from the Architecture document, UX Design specification, and existing project documentation into implementable stories. Each epic delivers user-visible value while progressively building the refactored architecture.

## Requirements Inventory

### Functional Requirements

FR1: Multi-booru browsing — 7 Philomena-powered booru hosts, each with independent filter configurations
FR2: Featured/Trending images — infinite-scroll trending feed with featured image banner
FR3: Search — full-text query with configurable sort field, sort direction, and per-booru filter
FR4: Gallery viewer — full-screen photo viewer with pinch-to-zoom + slideshow mode with configurable interval
FR5: Local favorites — SQLite-backed CRUD with favorite state toggle
FR6: Download management — download images/videos at selectable resolution
FR7: Share — share image files or image links
FR8: Dark mode — toggleable light/dark Material theme
FR9: Layout preferences — single/dual column grid toggle + configurable image sizes
FR10: i18n — English + Simplified Chinese
FR11: Cache management — separate image and video cache clearing

### NonFunctional Requirements

NFR1: Low module coupling — clear separation between layers, explicit import rules
NFR2: Agent-friendly development — ~80 lines per file, single responsibility; patterned code
NFR3: Testability — enable unit tests for Repository, Provider, and Strategy layers
NFR4: Dependency injection — get_it replacing singletons; composition root pattern
NFR5: Repository layer — ImageRepository + FavoritesRepository abstract interfaces

### Additional Requirements

AR1: get_it DI container — composition root only (main.dart), forbidden in Widget/Provider
AR2: ViewState<T> sealed class — Loading/Success/Failure pattern, mandatory for all async Providers
AR3: BooruApiStrategy pattern — abstract API version differences (v1 vs v3 response formats)
AR4: Dio interceptors — logging + auto-retry + unified error mapping
AR5: Result<T> data-layer sealed class — with FailureType enum routing
AR6: File splits — enums.dart → domain/enums/ + config/; home_page.dart → home + trending_scroll + home_drawer; search_model.dart → search_interface + search_provider
AR7: mocktail testing — Repository first, Provider second, Strategy third
AR8: snake_case filenames; PascalCase class names; one responsibility per file
AR9: ErrorMapper utility — centralized DioException → Failure conversion

### UX Design Requirements

UX-DR1: Skeleton loading grids — shimmer placeholders for trending/search/favorites
UX-DR2: Search empty state — "No results for '{query}'" with filter suggestions
UX-DR3: Favorites empty state — "No favorites yet" with usage guidance
UX-DR4: Offline banner — "You're offline — showing cached content" + disable search
UX-DR5: Gallery error retry — "Tap to retry" replacing static error icon
UX-DR6: Disable search button when input is empty
UX-DR7: Dark-mode tag color contrast fix — 11/12 categories below WCAG AA on #303030
UX-DR8: Gallery toolbar scrim — semi-transparent dark background behind white icons
UX-DR9: Optimistic toast timing — toast AFTER async success; show error message on failure
UX-DR10: Tooltips on all IconButtons — most are currently missing
UX-DR11: Extract hardcoded Chinese to .arb — 清除缓存, 关于, 单列模式, 夜间模式, 幻灯片间隔
UX-DR12: Date localization — DetailSheet uses system locale instead of hardcoded yyyy-MM-dd HH:mm
UX-DR13: Numeric formatting — stats display with locale separators
UX-DR14: Infinite-scroll tail indicator — loading widget at grid bottom
UX-DR15: Infinite-scroll sentinel — stop requests after data exhausted
UX-DR16: Gallery zoom state reset on page change
UX-DR17: Theme transition animation — 300ms cross-fade on light/dark switch
UX-DR18: Favorites refresh on return — reload data after favorites changed
UX-DR19: Cancel in-flight requests on booru switch; clear old booru data
UX-DR20: API key validation — error toast on 403 + key re-entry suggestion
UX-DR21: Uploader name tappable — implement missing tap action in DetailSheet

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 1 | Multi-booru browsing — Strategy pattern foundation |
| FR2 | Epic 1, 2 | Trending — UX skeleton/empty/error (E1), gallery polish (E2) |
| FR3 | Epic 1, 2 | Search — UX skeleton/empty/error (E1), remaining polish (E2) |
| FR4 | Epic 2, 3 | Gallery — core fixes (E2), animation/accessibility (E3) |
| FR5 | Epic 1, 2 | Favorites — data foundation (E1), UX polish (E2) |
| FR6 | Epic 2 | Download management (gallery toolbar) |
| FR7 | Epic 2 | Share (gallery toolbar) |
| FR8 | Epic 3 | Dark mode — contrast fix + theme animation |
| FR9 | Epic 3 | Layout preferences (file split) |
| FR10 | Epic 3 | i18n — hardcoded extraction + locale formatting |
| FR11 | Epic 1 | Cache management (Dio cache layer) |

## Epic List

### Epic 1: Confident Browsing — Search & Trending Foundation

Set up DI container, Repository interfaces, BooruApiStrategy, ViewState/Result sealed classes, Dio interceptors, error mapper — all enabling the UX: trending skeleton loading, search skeleton + empty state, error recovery (retry buttons), disable search when input empty.

**User Value:** Users see shimmer skeleton loading instead of blank screens. Search failures show clear error message + retry. Empty results show guidance.

**FRs covered:** FR1, FR2, FR3, FR5, FR11
**NFRs covered:** NFR1, NFR2, NFR4, NFR5
**ARs covered:** AR1, AR3, AR4, AR5, AR8, AR9
**UX-DRs covered:** UX-DR1, UX-DR2, UX-DR5, UX-DR6, UX-DR14, UX-DR15
**Tests:** Repository interface tests, Dio interceptor tests, Result sealed class tests, SearchProvider ViewState test

### Story 1.1: Set Up DI Container, Extract Enums, and Define Sealed Classes

As a developer,
I want a get_it DI container, pure enums extracted from the God file, and Result/ViewState/FailureType sealed classes,
So that all future code follows consistent dependency injection and state management patterns.

**Acceptance Criteria:**

**Given** the project has run `flutter pub get` with `get_it` dependency added
**When** `configureDependencies()` is called during main() initialization
**Then** the get_it container is configured for future state registration (Repository, ApiStrategy, Dio instances)
**And** `flutter analyze` passes with zero errors

**Given** the `lib/core/domain/` directory structure has been created
**When** a developer imports `import 'package:derpiviewer/core/domain/enums/booru.dart';`
**Then** the `Booru` enum is accessible with zero Flutter or config dependencies
**And** all 5 enum files (booru, sort_field, sort_direction, content_format, tag_category) are independently importable
**And** the original enums in `lib/enums.dart` have been removed

**Given** `lib/core/domain/result.dart` exists
**When** a developer calls a `Future<Result<List<ImageEntity>>>` method
**Then** `Result<T>` sealed class supports two variants: `Success<T>(T data)` and `Failure<T>(String message, FailureType type, Object? error, StackTrace? stackTrace)`
**And** `FailureType` enum contains: network, notFound, timeout, api, deserialization

**Given** `lib/core/domain/view_state.dart` exists
**When** a Provider exposes `ViewState<T> get state`
**Then** `ViewState<T>` sealed class supports three variants: `LoadingState<T>`, `SuccessState<T>(T data)`, `FailureState<T>(String message, FailureType type)`
**And** UI can render all three states using exhaustive switch

### Story 1.2: Create Repository Interfaces and BooruApiStrategy Pattern

As a developer,
I want abstract interfaces for ImageRepository and FavoritesRepository, and the BooruApiStrategy pattern for multi-booru API versions,
So that data access is testable and switching boorus requires zero client code changes.

**Acceptance Criteria:**

**Given** `lib/core/domain/repositories/image_repository.dart` exists
**When** a developer reads the interface
**Then** it declares methods: `getImage(Booru, int, {String? apiKey})`, `searchImages({required Booru, required String query, required SearchParams params, String? apiKey})`, `getFeaturedImage(Booru, {String? apiKey})`
**And** all return types are `Future<Result<T>>`

**Given** `lib/core/domain/repositories/favorites_repository.dart` exists
**When** a developer reads the interface
**Then** it declares methods: `getFavorites(Booru, int page, int perPage)`, `toggleFavorite(Booru, ImageEntity, bool isFaved)`, `isFavorite(Booru, int imageId)`
**And** all return types are `Future<Result<T>>`

**Given** the `BooruApiStrategy` abstract class is implemented
**When** `PhilomenaV1Strategy` (for derpi, trixie, pony, fur, ponerpics, mane) is instantiated
**Then** it has: host, searchPath (`/api/v1/json/search/images`), trendingPath (`/api/v1/json/images/featured`)
**And** `parseImageList` extracts `data["images"]` from JSON
**And** `parseFeatured` extracts `data["image"]` from JSON

**Given** `PhilomenaV3Strategy` (for twi) is instantiated
**When** same as above
**Then** searchPath = `/api/v3/search/posts`, trendingPath = `/api/v3/posts/featured`
**And** `parseImageList` extracts `data["posts"]` from JSON
**And** `parseFeatured` extracts `data["post"]` from JSON

### Story 1.3: Implement Repository Layer with Dio Interceptors

As a developer,
I want ImageRepositoryImpl, FavoritesRepositoryImpl, Dio interceptors, and a unified error mapper,
So that all data access flows through consistent, testable interfaces.

**Acceptance Criteria:**

**Given** `ImageRepositoryImpl` is created
**When** `searchImages()` is called
**Then** it uses `BooruApiStrategyFactory` to select the correct strategy, makes HTTP calls via the strategy's Dio instance, parses the response, and returns `Result<List<ImageEntity>>`
**And** no Dio details leak into the return value — all JSON parsing is internal to the implementation

**Given** `FavoritesRepositoryImpl` is created
**When** `toggleFavorite()` is called
**Then** it writes to SQLite via `FavoritesLocalSource` and returns `Result<void>`
**And** `isFaved = true` causes INSERT; `false` causes DELETE

**Given** Dio instances are configured at strategy creation time
**When** any API request fails with DioException
**Then** the `error_mapper.dart` function converts DioException to Failure: `DioExceptionType.connectionError` → `FailureType.network`, `DioExceptionType.badResponse(404)` → `FailureType.notFound`, `DioExceptionType.badResponse(403)` → `FailureType.api`, `DioExceptionType.receiveTimeout` → `FailureType.timeout`
**And** automatic retry fires up to 3 times with exponential backoff for network errors
**And** request/response is logged via `developer.log()`

### Story 1.4: Migrate SearchProvider to ViewState with Skeleton, Empty State, and Error Recovery

As a user,
I want to see a skeleton screen while search loads, a helpful empty state when nothing is found, and a retry button on network error,
So that the search experience feels smooth and informative at every stage.

**Acceptance Criteria:**

**Given** SearchProvider receives `ImageRepository` via constructor injection
**When** the user submits a search query
**Then** SearchProvider sets `state` to `LoadingState()`, notifying listeners
**And** the UI renders `SkeletonGrid` (6 placeholder cards with shimmer animation)

**Given** a search returns zero results
**When** the API responds successfully with 0 images
**Then** SearchProvider sets `state` to `SuccessState([])` (empty list)
**And** the UI renders a centered illustration + "No results for '{query}'" + "Try different search terms or check your filter settings."

**Given** a search fails with a network error
**When** Repository returns `Failure(message, type: FailureType.network)`
**Then** SearchProvider sets `state` to `FailureState(message, type)`, notifying listeners
**And** the UI renders `ErrorView` with the error message + "Retry" button
**And** tapping "Retry" calls `search(query)` again

**Given** the search input is empty
**When** the user opens SearchPage
**Then** the search button is disabled (grey, not tappable)
**And** typing any character enables the search button
**And** clearing all characters disables it again

### Story 1.5: Migrate TrendingProvider to ViewState with Skeleton, Error, and Infinite-Scroll Fixes

As a user,
I want to see a skeleton screen while trending loads, infinite scroll without stalling, and a retry button on network error,
So that browsing trending images feels seamless and reliable.

**Acceptance Criteria:**

**Given** TrendingProvider receives `ImageRepository` via constructor injection
**When** the app starts and trending feed loads for the first time
**Then** the UI renders: FeaturedImageBanner skeleton + `SkeletonGrid` (6 placeholder cards) below it
**And** when data arrives, the skeleton is replaced with real FeaturedImage + ImageGrid (fade-in animation)

**Given** the user scrolls down through trending
**When** scroll reaches the end of the grid
**Then** if more pages exist (`hasMore == true`), `fetchMore()` triggers
**And** a tail loading indicator (`CircularProgressIndicator`) appears at the grid bottom
**And** when `over == true` (no more results), no further fetch calls fire, loading indicator disappears
**And** when content is shorter than viewport height, no continuous fetch loop occurs

**Given** a network error occurs during trending browsing
**When** fetchMore fails with `FailureType.network`
**Then** if this is the first load (no existing content), show `ErrorView` + retry
**And** if content already exists and fetchMore fails, show a non-intrusive snackbar — "Failed to load more. Tap to retry." — without replacing the existing grid

### Story 1.6: Write Epic 1 Tests

As a developer,
I want automated tests for the repositories, strategies, sealed classes, and DI container built in Epic 1,
So that the Epic 1 refactoring is safely validated before subsequent work continues.

**Acceptance Criteria:**

**Given** `test/core/domain/result_test.dart`
**When** `flutter test` runs
**Then** tests verify: `Success<T>` holds data, `Failure<T>` holds message + type + error, pattern matching works with exhaustive switch

**Given** `test/core/data/datasources/strategies/philomena_v1_strategy_test.dart` + `philomena_v3_strategy_test.dart`
**When** `flutter test` runs
**Then** tests verify with fixture JSON files: `parseImageList` returns correct count of ImageDto, `parseFeatured` returns correct image, v1 extracts from `data["images"]`, v3 extracts from `data["posts"]`

**Given** `test/core/data/repositories/image_repository_impl_test.dart`
**When** `flutter test` runs with mock Dio + mock ApiStrategy
**Then** tests verify: searchImages returns correctly mapped Success<List<ImageEntity>>, DioException maps to correct FailureType, retry fires at Dio interceptor level

**Given** `test/core/di/injection_container_test.dart`
**When** `flutter test` runs
**Then** tests verify: all get_it registrations resolve without exceptions, `getIt<ImageRepository>()` returns ImageRepositoryImpl instance, `getIt<FavoritesRepository>()` returns FavoritesRepositoryImpl instance

### Epic 2: Gallery & Favorites Excellence

Migrate Gallery + Favorites Providers to ViewState. Fix toast timing, gallery toolbar scrim, gallery error retry, zoom reset on page change, favorites empty state, favorites refresh on return, infinite-scroll sentinel + tail indicator.

**User Value:** Gallery toolbar icons are visible (no longer blend into light images). Image load failures → tap to retry. Favorites work perfectly — no stale data, no wrong toasts, useful empty state guidance.

**FRs covered:** FR2, FR3, FR4, FR5, FR6, FR7
**NFRs covered:** NFR1, NFR2, NFR3
**ARs covered:** AR2, AR6
**UX-DRs covered:** UX-DR3, UX-DR5, UX-DR8, UX-DR9, UX-DR16, UX-DR18
**Tests:** Gallery Provider ViewState test, Favorites Provider test, widget tests for key flows

### Story 2.1: Migrate GalleryView + GalleryToolbar to ViewState with Scrim, Retry, and Zoom Reset

As a user,
I want gallery toolbar icons to be visible against any background, failed images to offer a retry button, and zoom level to reset when I swipe to the next image,
So that the full-screen viewing experience is polished and frustration-free.

**Acceptance Criteria:**

**Given** GalleryToolbar is rendered as an overlay on GalleryView
**When** the toolbar icons (favorite, download, share, info) are displayed
**Then** a semi-transparent dark scrim (`Colors.black54` with 40% opacity) is rendered behind the icon Row
**And** icons remain `#FFFFFF` with scrim ensuring visibility on light images

**Given** a gallery image fails to load
**When** CachedNetworkImage encounters an error
**Then** instead of a static `Icons.error_outline`, the error state shows: error icon + "Failed to load image" text + "Tap to retry" button
**And** tapping retry re-initializes the image load for the current index

**Given** a video fails to load in the gallery
**When** Chewie/VideoPlayer encounters an error
**Then** instead of a static `Icons.error_outline` (50px, no retry), the error state shows: error icon + "Failed to load video" + "Tap to retry" button

**Given** the user is viewing an image at zoom level > 1.0×
**When** the user swipes to the next image
**Then** the zoom level resets to 1.0× (contained) for the new image
**And** the previous image's zoom state does not carry over

**Given** a gallery image loads successfully
**When** the image is displayed in PhotoViewGallery
**Then** the loading indicator (`CircularProgressIndicator` with determinate progress) is shown during load
**And** the progress indicator is replaced by the image when loading completes

### Story 2.2: Migrate FavoritesProvider to ViewState with Empty State, Refresh, and Toast Fix

As a user,
I want to see a helpful empty state when I have no favorites, see up-to-date data when I return to favorites, and get accurate toast confirmations,
So that managing my favorites collection is reliable and intuitive.

**Acceptance Criteria:**

**Given** FavoritesProvider receives `FavoritesRepository` via constructor injection
**When** the user navigates to FavouritePage with zero favorites
**Then** FavoritesProvider sets `state` to `SuccessState([])` (empty list)
**And** the UI renders a centered heart-outline illustration + "No favorites yet" + "Tap the heart icon on any image in the gallery to save it here."

**Given** the user has favorited images
**When** they unfavorite an image in GalleryView and navigate back to FavouritePage
**Then** FavouritePage triggers `fetchMore(refresh: true)` when it regains visibility
**And** the unfavorited image no longer appears in the grid

**Given** the user taps the favorite icon in the GalleryToolbar
**When** the toggle action is triggered
**Then** the toast message fires AFTER the DB write completes successfully — not before
**And** if faved: toast shows "Added to favorites" after DB INSERT succeeds
**And** if unfaved: toast shows "Removed from favorites" after DB DELETE succeeds
**And** if the DB operation fails: toast shows "Failed to update favorite" instead of a false positive confirmation

**Given** the user rapidly toggles the favorite icon
**When** multiple taps fire in quick succession
**Then** a lock/mutex prevents concurrent DB writes (using existing `synchronized` package or `_isLocked` pattern)
**And** only the final intended state is persisted

### Story 2.3: Write Epic 2 Widget Tests

As a developer,
I want widget tests for the GalleryView error/retry flow and the FavouritePage empty state and refresh behavior,
So that the UX fixes in Epic 2 are protected against regression.

**Acceptance Criteria:**

**Given** `test/ui/widgets/gallery_error_retry_test.dart`
**When** `flutter test` runs
**Then** tests verify: error state renders retry button, tapping retry re-triggers image load, zoom resets on page change

**Given** `test/ui/pages/fav_page_test.dart`
**When** `flutter test` runs with mock FavoritesRepository
**Then** tests verify: empty state renders with illustration and guidance text, data refreshes when page regains visibility, toast timing matches DB result

**Given** `test/ui/providers/fav_provider_test.dart`
**When** `flutter test` runs
**Then** tests verify: Loading → Success transition, Loading → Failure transition, toggle write failure does not change UI state, rapid toggle mutex prevents concurrent writes

### Epic 3: Polished Application Experience

File splits (home_page, search_model, enums, dialogs), reusable ErrorView widget, dark mode tag color contrast fix, theme transition animation, tooltips on all IconButtons, hardcoded Chinese extraction to .arb, date/number locale formatting, booru switch cancel in-flight requests, API key validation on 403, uploader name tappable, offline banner.

**User Value:** Dark mode tags are readable. Theme switches with animation. Every icon button has a tooltip. Full bilingual parity. Offline state has clear indicator. Bug fixes eliminate crashes.

**FRs covered:** FR4, FR8, FR9, FR10
**NFRs covered:** NFR1, NFR2, NFR3
**ARs covered:** AR2, AR6, AR7
**UX-DRs covered:** UX-DR4, UX-DR7, UX-DR10, UX-DR11, UX-DR12, UX-DR13, UX-DR17, UX-DR19, UX-DR20, UX-DR21
**Tests:** Remaining widget tests, integration tests

### Story 3.1: File Splits and Reusable ErrorView Widget

As a developer,
I want large files split by responsibility and a reusable ErrorView widget,
So that every file has a single clear purpose and error states render consistently across the app.

**Acceptance Criteria:**

**Given** `lib/pages/home_page.dart` (323 lines, 3 widgets)
**When** the split is complete
**Then** three files exist: `home_page.dart` (HomePage + main Scaffold), `ui/widgets/trending_scroll.dart` (TrendingScroll), `ui/widgets/home_drawer.dart` (HomeDrawer)
**And** each file is under 150 lines
**And** `flutter analyze` passes with zero errors on the new files

**Given** `lib/models/search_model.dart` (pairing interface + implementation)
**When** the split is complete
**Then** two files exist: `core/domain/search_interface.dart` (abstract, no Flutter deps) and `ui/providers/search_provider.dart` (ChangeNotifier implementation)
**And** `FavModel` imports only `search_interface.dart`, not the implementation

**Given** `lib/enums.dart` (255 lines, 8 concerns)
**When** the split is complete
**Then** pure enums live in `core/domain/enums/` (5 files), host/path/filter config lives in `config/booru_config.dart`, tag categories + colors live in `config/tag_categories.dart`, fallback URLs + MIME types live in `config/constants.dart`
**And** `ConstStrings` class no longer exists; all config is accessed via dedicated files
**And** no file imports BuildContext for l10n lookups — l10n resolution stays in the UI layer

**Given** 7 dialog widgets live in `lib/widgets/dialogs.dart`
**When** the split is complete
**Then** 7 files exist under `ui/widgets/dialogs/`: `booru_dialog.dart`, `search_params_dialog.dart`, `download_prefs_dialog.dart`, `api_key_dialog.dart`, `cache_dialog.dart`, `about_dialog.dart`, `slideshow_dialog.dart`
**And** each file contains exactly one dialog class

**Given** `lib/ui/widgets/error_view.dart` is created
**When** any Provider enters `FailureState`
**Then** all error UIs use the same `ErrorView` widget: icon + localized message + retry button
**And** the widget accepts `String message, VoidCallback onRetry` parameters

### Story 3.2: Dark Mode Tag Contrast Fix and Theme Transition Animation

As a user,
I want tag chips to be readable in dark mode and theme switching to animate smoothly,
So that the app feels polished in both light and dark themes.

**Acceptance Criteria:**

**Given** the app is in dark mode (`ThemeData.dark()` with `#303030` scaffold background)
**When** the user opens a DetailSheet with tag chips
**Then** all 12 tag category foreground colors meet WCAG AA contrast ratio (≥4.5:1) against `#303030`
**And** the `body` tag category is visible (no longer 1.9:1 contrast ratio)
**And** tag chips retain their category identity (background color distinguishes general from artist from rating, etc.)

**Given** `config/tag_categories.dart` defines color pairs
**When** a developer reads the config
**Then** each TagCategory entry has: `backgroundColor`, `foregroundLight`, `foregroundDark` (three values per category)
**And** the DetailSheet selects foregroundDark or foregroundLight based on the current theme

**Given** the user toggles the dark mode switch in the drawer
**When** `PrefModel.toggleDarkMode()` fires
**Then** the theme transition uses a 300ms cross-fade animation (`AnimatedTheme` or a custom `ThemeTransition` wrapper)
**And** the transition is smooth with no jarring flash

### Story 3.3: i18n Extraction and Accessibility

As a user,
I want all UI text to respect my language choice, dates and numbers formatted for my locale, and every icon button to have a descriptive tooltip,
So that the app feels native regardless of language setting and is accessible to screen reader users.

**Acceptance Criteria:**

**Given** the app language is set to English
**When** the user opens the drawer
**Then** ALL items display in English: "Clear Cache" (not 清除缓存), "About" (not 关于), "Single Column Mode" (not 单列模式), "Dark Mode" (not 夜间模式), "Slideshow Interval" (not 幻灯片间隔)
**And** the 5 hardcoded strings have been extracted to `app_en.arb` and `app_zh.arb`
**And** the drawer code uses `AppLocalizations.of(context)!.drawerClearCache`, etc.

**Given** the user views the DetailSheet
**When** the image creation date is displayed
**Then** the date format respects the system locale (e.g., "June 4, 2026 15:30" for en_US, "2026年6月4日 15:30" for zh_CN)
**And** the stats numbers use locale separators (e.g., "1,234" for en_US, "1 234" for locale-appropriate grouping)

**Given** any `IconButton` in the app (AppBar, GalleryToolbar, Drawer, FABs)
**When** the user long-presses or hovers
**Then** a tooltip appears with a descriptive label
**And** missing tooltips are added to: drawer items, FABs, gallery toolbar icons, search page action buttons
**And** `Semantics` widget wraps key interactive elements with `semanticLabel` for screen reader support

### Story 3.4: Bug Fixes — Booru Switch Cancel, API Key Validation, Uploader Tap, Offline Banner

As a user,
I want switching boorus to not mix data, invalid API keys to show clear errors, uploader names to be tappable, and offline mode to be clearly indicated,
So that the app handles edge cases gracefully and never shows wrong or confusing data.

**Acceptance Criteria:**

**Given** the user switches boorus (e.g., from trixie to derpi)
**When** `PrefModel.changeHost(newBooru)` fires
**Then** all in-flight API requests for the previous booru are cancelled
**And** the trending/search grid clears before showing new booru data
**And** a loading state is shown while the new booru's data loads
**And** no images from the old booru appear in the new booru's grid

**Given** a user has entered an invalid or expired API key
**When** any API request returns HTTP 403
**Then** the error mapper produces `FailureType.api` with message "API key invalid or expired"
**And** the UI shows a non-intrusive snackbar: "API key rejected. Update it in Settings." with an action to open ChangeKeyDialog

**Given** the user views a DetailSheet
**When** they tap the uploader name ( displayed in blue `{colors.semantic.uploader-link}` )
**Then** it navigates to SearchPage with `uploader:{name}` pre-filled (or copies uploader name to clipboard with toast — matching existing tag behavior if search by uploader is not supported)

**Given** the device loses network connectivity
**When** the app detects offline state
**Then** a non-intrusive banner appears at the top of HomePage/ResultPage: "You're offline — showing cached content."
**And** the search button on the FAB remains tappable but the SearchPage shows: "Search requires an internet connection." with a disabled search button
**And** Favorites continue working fully (SQLite local)
**And** when connectivity returns, the banner dismisses automatically

### Story 3.5: Write Remaining Widget and Integration Tests

As a developer,
I want widget tests for the remaining migrated pages and integration tests for key user flows,
So that the full refactoring is validated and all UX fixes are protected against regression.

**Acceptance Criteria:**

**Given** `test/ui/widgets/detail_sheet_test.dart`
**When** `flutter test` runs
**Then** tests verify: tag colors respect theme (light foreground on light, dark foreground on dark), date displays with locale formatting, uploader name is tappable

**Given** `test/ui/pages/home_page_test.dart`
**When** `flutter test` runs
**Then** tests verify: drawer renders all items with correct AppLocalizations strings (not hardcoded Chinese), dark mode toggle triggers theme transition, booru switch clears and reloads grid

**Given** `test/integration/search_flow_test.dart`
**When** `flutter test --dart-define=integration=true` runs
**Then** tests verify: open app → tap search FAB → type query → see skeleton → see results → tap result → see gallery → swipe → see next image

**Given** `test/integration/favorites_flow_test.dart`
**When** integration tests run
**Then** tests verify: open gallery → tap heart → toast confirms → navigate to favorites → see favorited image → unfavorite → return to favorites → image is gone

**Given** all test files from Epics 1, 2, and 3
**When** `flutter test` runs the full suite
**Then** all tests pass with zero failures
**And** `flutter analyze` passes with zero errors
