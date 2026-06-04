# Deferred Work

## Deferred from: code review of 1-1-di-container-enums-sealed-classes (2026-06-04)

- SearchModel._fetchResult shadows `over` class field causing infinite API calls — `lib/models/search_model.dart:36`. Local variable `bool over` shadows `this.over`. Remove local declaration; operate on class field directly.
- Unhandled exceptions from fetchMore in Provider update callbacks — `lib/main.dart:25-37`. Wrap fetchMore calls in .catchError() or add error state tracking.
- .gitignore entry ".gitignore" self-ignores — `.gitignore:54`. Remove `.gitignore` from the ignore list.
- _bmad pattern doesn't match _bmad-output/ directory — `.gitignore:53`. Change to `_bmad*` or `_bmad/**`.
- ConstStrings.format/mime lists coupled to ContentFormat enum index ordering — `lib/enums.dart`, `lib/api/do.dart`. Add compile-time tests verifying list lengths match enum value counts, or add `toApiString()` method to ContentFormat.
- ContentFormat.values[-1] RangeError on unknown API format — `lib/api/do.dart:78,101`. Add guard for indexOf returning -1; fall back to sensible default.
- downloadFile switch default leaves bs null — `lib/helpers/download.dart:55-76`. Remove default branch or throw UnimplementedError.
- helper.dart appendClipboard fires-and-forgets Future — `lib/helpers/helper.dart:7`. Await or remove async.
- PrefModel getPref() uses imageSize.index as fallback for all size types — `lib/models/pref_model.dart:82-85`. Use explicit defaults per category.
- _pageController.page! forced unwrap may crash — `lib/pages/gallery.dart:67,138,153`. Guard with null check before using.

## Deferred from: code review of story 1.4 (2026-06-04)

- `getItemCount()` vs `getItem()` TOCTOU race in `SearchProvider` — pre-existing pattern in all `SearchInterface` implementations (SearchModel, FavModel, TrendingModel). Not new to this story. [`lib/ui/providers/search_provider.dart:163,205`]
- `addHistory` mutates `_prefProvider.history` directly — matches existing `SearchModel.addHistory` behavior exactly; preserving backward compat. [`lib/ui/providers/search_provider.dart:150-154`]
- `getItemUrl` emits empty string on failed size lookup in `SearchProvider` — same fallback pattern as old `SearchModel.getItemUrl`. [`lib/ui/providers/search_provider.dart:178-181`]
- `perPage: 0` causes infinite `_hasMore` in `SearchProvider` — pre-existing issue in `PrefModel.getPref()`, not introduced by this change. [`lib/ui/providers/search_provider.dart:82-83`]
- `ImageResponse.fromEntity` performs no validation — entity fields should be valid by construction; pre-existing pattern with other constructors. [`lib/api/do.dart:91-134`]

## Deferred from: code review of 2-1-gallery-viewstate-scrim-retry-zoom-reset (2026-06-04)

- `_retryCounts` map grows without bound — no eviction policy; practical impact minimal per entry is one int. [`lib/pages/gallery.dart:34`]
- Retry buttons lack tap debouncing — minor UX concern; rapid-tap case unlikely in practice. [`lib/pages/gallery.dart:107-109`, `lib/widgets/video_view.dart:62-68`]
- Zoom reset verification not visible in diff — PhotoViewGallery internal `ObjectKey(index)` + `initialScale` already handles reset; verified in photo_view-0.14.0 source. [`lib/pages/gallery.dart`]
- Image fade transition not explicitly added — CachedNetworkImage has built-in fade-in behavior; explicit AnimatedSwitcher only added for video. [`lib/pages/gallery.dart:96-112`]

## Deferred from: code review of 3-1-file-splits-error-view-widget (2026-06-05)

- Lock in StatelessWidget renders synchronization ineffective — `GalleryToolBar` is a `StatelessWidget` but holds `final Lock _toggleLock`. Parent rebuilds create new instances with new Locks, defeating the debounce/sync intent. [`lib/widgets/toolbar.dart:41`]
- Video error retry operates on soon-to-be-disposed widget — `ErrorView.onRetry` triggers parent rebuild which unmounts the old `VideoView`, but `_initializeVideoPlayer()` is called on the old widget. Wasted I/O and resource allocation. [`lib/widgets/video_view.dart:89-94`]
- `_isInitializing` deadlock prevents retry on hung initialization — if `_initializeVideoPlayer` hangs mid-way (e.g., cache fetch stalls), `_isInitializing` stays true permanently and all retries are silently dropped. [`lib/widgets/video_view.dart:25,90`]
- Near-duplicate test files for FavoritesProvider — `fav_page_test.dart` and `favorites_provider_test.dart` share nearly identical mock/entity setup. Maintenance burden: changes to FavoritesProvider require updating both files. [`test/ui/pages/fav_page_test.dart`, `test/ui/providers/favorites_provider_test.dart`]
- Search path fallback uses trending path instead of search path — `booruSearchPaths[booru] ?? defaultTrendingPath` should use `defaultSearchPath` as fallback. All current enum values covered, no immediate impact. [`lib/api/clients.dart:93-94`]
- Weak smoke-test assertions in gallery toolbar test — only checks `findsWidgets` for IconButton and Container; no specific count or interaction testing. [`test/ui/widgets/gallery_toolbar_scrim_test.dart:34-35`]
- VideoView retry not wired to GalleryView retry mechanism — `VideoView` in gallery is called without `onRetry` parameter, so retry stays in local loop without engaging parent's `_retryCounts` / key-change mechanism. [`lib/pages/gallery.dart:91-93`]
- formatExtensions/mimeTypes must be manually kept in sync with ContentFormat — index-based lookup will crash with RangeError if lists desync. Currently correct; no test enforces the invariant. [`lib/config/constants.dart:8-26`]
- booruFilters[b]! crashes for unknown Booru enum values — null-assert at multiple call sites; if a new Booru value is added without a filters entry, runtime crash. Same pattern as pre-existing ConstStrings code. [`lib/models/pref_model.dart:52-98`, `lib/ui/widgets/dialogs/search_params_dialog.dart:16`]
- _retryCounts map grows without bound — no eviction policy; practical impact minimal (one int per failed index). Acknowledged in previous deferred-work entry. [`lib/pages/gallery.dart:34`]
- SearchProvider error handling differs from FavoritesProvider — on pagination error, SearchProvider replaces entire grid with ErrorView (losing loaded pages) while FavoritesProvider preserves existing data. Pre-existing pattern. [`lib/ui/providers/search_provider.dart:165-168`]
- No format-string fallback in ImageResponse constructors vs ImageEntity — ImageResponse crashes on unrecognized format strings from API (`indexOf` returns -1), while ImageEntity gracefully degrades with `>= 0` guard. Pre-existing inconsistency. [`lib/api/do.dart:75,125`]
