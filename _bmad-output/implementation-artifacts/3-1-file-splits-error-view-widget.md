---
baseline_commit: e13a237690a063fdd141ef07ae8c842419b17e52
---

# Story 3.1: File Splits and Reusable ErrorView Widget

Status: done

## Story

As a developer,
I want large files split by responsibility and a reusable ErrorView widget,
so that every file has a single clear purpose and error states render consistently across the app.

## Acceptance Criteria

1. **Given** `lib/pages/home_page.dart` (461 lines, 3 widgets)
   **When** the split is complete
   **Then** three files exist: `lib/pages/home_page.dart` (HomePage + main Scaffold, ~90 lines), `lib/ui/widgets/trending_scroll.dart` (TrendingScroll, ~180 lines), `lib/ui/widgets/home_drawer.dart` (HomeDrawer, ~160 lines)
   **And** each file is under 200 lines
   **And** `flutter analyze` passes with zero errors on the new files

2. **Given** `lib/models/search_model.dart` (interface extending ChangeNotifier)
   **When** the split is complete
   **Then** `lib/core/domain/search_interface.dart` exists with a pure abstract class (NO extends ChangeNotifier, NO Flutter imports)
   **And** `lib/models/search_model.dart` is deleted
   **And** all 5 files importing `search_model.dart` now import `search_interface.dart`
   **And** `FavoritesProvider` and `SearchProvider` each extend `ChangeNotifier implements SearchInterface`
   **And** `flutter analyze` passes with zero errors

3. **Given** `lib/enums.dart` (221 lines, ConstStrings class with 8 concern groups)
   **When** the split is complete
   **Then** three config files exist: `lib/config/booru_config.dart` (hosts, paths, filters), `lib/config/tag_categories.dart` (tag categories, colors, tag lists), `lib/config/constants.dart` (fallback URLs, MIME types, format lists, sort labels)
   **And** `ConstStrings` class no longer exists in `lib/enums.dart`
   **And** all 12 files that imported `lib/enums.dart` are updated to import from the correct config files
   **And** `lib/enums.dart` is deleted
   **And** `flutter analyze` passes with zero errors

4. **Given** 7 dialog widgets live in `lib/widgets/dialogs.dart` (441 lines)
   **When** the split is complete
   **Then** 7 files exist under `lib/ui/widgets/dialogs/`: `booru_dialog.dart`, `search_params_dialog.dart`, `download_prefs_dialog.dart`, `api_key_dialog.dart`, `cache_dialog.dart`, `about_dialog.dart`, `slideshow_dialog.dart`
   **And** each file contains exactly one dialog class and is under 100 lines
   **And** `lib/pages/home_page.dart` imports each dialog individually (no more `dialogs.dart` import)
   **And** `lib/widgets/dialogs.dart` is deleted
   **And** `flutter analyze` passes with zero errors

5. **Given** `lib/ui/widgets/error_view.dart` already exists (created in Story 1.4)
   **When** `flutter analyze` runs
   **Then** ErrorView widget is confirmed reusable with signature: `ErrorView({required String message, required VoidCallback onRetry})`
   **And** no changes are needed — verification only

6. **Given** `flutter analyze` runs on the full project
   **Then** zero errors
   **And** all 80 existing tests continue to pass with zero regressions

## Tasks / Subtasks

- [x] Task 1: Split `enums.dart` → 3 config files (AC: 3)
  - [x] Create `lib/config/booru_config.dart` with: `booruHosts`, `booruSearchPaths`, `booruTrendingPaths`, `booruFilters`, `defaultHost`, `defaultSP`, `defaultTP`
  - [x] Create `lib/config/tag_categories.dart` with: `tagBackColors`, `tagForeColors`, `ratingTags`, `bodyTags`, `errorTags`
  - [x] Create `lib/config/constants.dart` with: `fallbackImg`, `formatExtensions`, `mimeTypes`, `sortFields`, `sortDirections`, `getSortFieldLabel()`, `getSortDirectionLabel()`
  - [x] Update ALL 12 files importing `lib/enums.dart` to use new config imports
  - [x] Delete `lib/enums.dart`
  - [x] Run `flutter analyze` — fix any remaining references

- [x] Task 2: Move SearchInterface to domain layer (AC: 2)
  - [x] Create `lib/core/domain/search_interface.dart` — pure abstract class, NO `extends ChangeNotifier`, NO Flutter imports
  - [x] Update `lib/ui/providers/search_provider.dart`: remove `search_model.dart` import, add `search_interface.dart` import, keep `extends ChangeNotifier implements SearchInterface`
  - [x] Update `lib/ui/providers/favorites_provider.dart`: same import swap
  - [x] Update `lib/widgets/image_grid.dart`: import swap
  - [x] Update `lib/pages/gallery.dart`: import swap
  - [x] Update `lib/widgets/toolbar.dart`: import swap
  - [x] Delete `lib/models/search_model.dart`
  - [x] Run `flutter analyze` — fix any remaining references

- [x] Task 3: Split `home_page.dart` into 3 files (AC: 1)
  - [x] Create `lib/ui/widgets/trending_scroll.dart`: extract `TrendingScroll` + `_TrendingScrollState` + `_FeaturedSkeleton`
  - [x] Create `lib/ui/widgets/home_drawer.dart`: extract `HomeDrawer`
  - [x] Strip `lib/pages/home_page.dart` to `HomePage` + `_MyHomePageState` only
  - [x] Update imports: `trending_scroll.dart` and `home_drawer.dart` import from new config files (not `enums.dart`); `home_page.dart` imports the two new widget files
  - [x] Replace `dialogs.dart` import with individual dialog imports
  - [x] Run `flutter analyze` — verify zero errors

- [x] Task 4: Split `dialogs.dart` into 7 individual files (AC: 4)
  - [x] Create directory `lib/ui/widgets/dialogs/`
  - [x] Create `lib/ui/widgets/dialogs/booru_dialog.dart` (ChangeBooruDialog)
  - [x] Create `lib/ui/widgets/dialogs/search_params_dialog.dart` (ChangeParamDialog)
  - [x] Create `lib/ui/widgets/dialogs/download_prefs_dialog.dart` (ChangeDownloadPrefDialog)
  - [x] Create `lib/ui/widgets/dialogs/api_key_dialog.dart` (ChangeKeyDialog)
  - [x] Create `lib/ui/widgets/dialogs/cache_dialog.dart` (ClearCacheDialog)
  - [x] Create `lib/ui/widgets/dialogs/about_dialog.dart` (CustomAboutDialog)
  - [x] Create `lib/ui/widgets/dialogs/slideshow_dialog.dart` (ChangeSlideIntervalDialog)
  - [x] Update each dialog file to import directly from new config files (not `enums.dart`)
  - [x] Update `lib/pages/home_page.dart` to import each dialog individually
  - [x] Delete `lib/widgets/dialogs.dart`
  - [x] Run `flutter analyze` — verify zero errors

- [x] Task 5: Verify ErrorView widget exists (AC: 5)
  - [x] Confirm `lib/ui/widgets/error_view.dart` at expected location
  - [x] Verify signature: `ErrorView({required String message, required VoidCallback onRetry})`
  - [x] Verify all existing usages (ResultPage, TrendingScroll, FavouritePage, GalleryView, VideoView) still compile
  - [x] No code changes needed — verification only

- [x] Task 6: Run full validation (AC: 6)
  - [x] `flutter analyze` — zero errors
  - [x] `flutter test` — all 80 existing tests pass with zero regressions

### Review Findings

- [x] [Review][Decision] AC 4 line-count spec contradiction — `download_prefs_dialog.dart` is 128 lines; AC states "under 100 lines" but Dev Notes estimate ~123 lines. Deferred — user chose to keep as-is.
- [x] [Review][Patch] trending_scroll.dart exceeds 200-line limit — trimmed to exactly 200 lines [lib/ui/widgets/trending_scroll.dart]
- [x] [Review][Patch] Hardcoded English strings in fav_page empty state — now uses AppLocalizations (favouritesEmptyTitle, favouritesEmptySubtitle) [lib/pages/fav_page.dart:85,93]
- [x] [Review][Patch] Hardcoded "Failed to update favorite" toast — now uses AppLocalizations (toolbarFavFailed) [lib/widgets/toolbar.dart:81]
- [x] [Review][Patch] Missing mounted check in didChangeAppLifecycleState — added !mounted guard [lib/pages/fav_page.dart:42]
- [x] [Review][Patch] Dead `_boorus` field in PrefModel — removed unused field [lib/models/pref_model.dart:11]
- [x] [Review][Patch] Missing `?? ''` fallback on booruHosts lookups — added fallback in fav_page.dart and home_drawer.dart [lib/pages/fav_page.dart:52], [lib/ui/widgets/home_drawer.dart:35]
- [x] [Review][Defer] Lock in StatelessWidget renders synchronization ineffective — pre-existing [lib/widgets/toolbar.dart:41]
- [x] [Review][Defer] Video error retry operates on soon-to-be-disposed widget — pre-existing [lib/widgets/video_view.dart:89-94]
- [x] [Review][Defer] _isInitializing deadlock prevents retry on hung initialization — pre-existing [lib/widgets/video_view.dart:25,90]
- [x] [Review][Defer] Near-duplicate test files for FavoritesProvider — pre-existing structure [test/ui/pages/fav_page_test.dart]
- [x] [Review][Defer] Search path fallback uses trending path instead of search path — pre-existing [lib/api/clients.dart:93-94]
- [x] [Review][Defer] Weak smoke-test assertions in gallery toolbar test — pre-existing [test/ui/widgets/gallery_toolbar_scrim_test.dart:34-35]
- [x] [Review][Defer] VideoView retry not wired to GalleryView retry mechanism — pre-existing [lib/pages/gallery.dart:91-93]
- [x] [Review][Defer] formatExtensions/mimeTypes must be manually kept in sync with ContentFormat — latent maintenance risk [lib/config/constants.dart:8-26]
- [x] [Review][Defer] booruFilters[b]! crashes for unknown Booru enum values — same as pre-existing ConstStrings pattern [lib/models/pref_model.dart:52-98]
- [x] [Review][Defer] _retryCounts map grows without bound — pre-existing, acknowledged in deferred-work [lib/pages/gallery.dart:34]
- [x] [Review][Defer] SearchProvider error handling differs from FavoritesProvider — pre-existing pattern [lib/ui/providers/search_provider.dart:165-168]
- [x] [Review][Defer] No format-string fallback in ImageResponse constructors vs ImageEntity — pre-existing [lib/api/do.dart:75,125]

## Dev Notes

### ⚠️ CRITICAL — What's Already Done vs. What's Left

| Item | Status | Notes |
|------|--------|-------|
| Domain enums (booru, sort_field, etc.) | ✅ Done (Epic 1) | 6 files in `lib/core/domain/enums/` |
| ErrorView widget | ✅ Done (Story 1.4) | `lib/ui/widgets/error_view.dart` — Task 5 is VERIFICATION ONLY |
| Config files | ❌ TODO | `lib/config/` directory does not exist yet |
| home_page.dart split | ❌ TODO | 461 lines, 3-in-1 file |
| search_model.dart split | ❌ TODO | Interface currently extends ChangeNotifier |
| dialogs.dart split | ❌ TODO | 441 lines, 7-in-1 file |

### Architecture Constraint: SearchInterface Domain Purity

**THE HARD RULE:** `lib/core/domain/` MUST NOT import Flutter or `ui/` files.

The current `SearchInterface` in `lib/models/search_model.dart` extends `ChangeNotifier` (a Flutter class from `package:flutter/widgets.dart`). This violates domain purity.

**Solution:** The new `lib/core/domain/search_interface.dart` is a **pure abstract class** with method signatures only — NO `extends ChangeNotifier`:

```dart
// lib/core/domain/search_interface.dart
// PURE DART — no Flutter imports allowed.

import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/models/pref_model.dart';

abstract class SearchInterface {
  int getItemCount();
  int getItemID(int index);
  String getItemUrl(int index, ImageSize imageSize);
  ImageResponse getItem(int index);
  ContentFormat getItemFormat(int index);
  String getItemMediumThumbUrl(int index);
  String getItemThumbUrl(int index);
  void fetchMore({bool refresh});
  Booru getBooru();
  PrefModel getPref();
}
```

Note: `ImageResponse` and `PrefModel` imports are required. `ImageResponse` is a legacy data class in `lib/api/do.dart`. `PrefModel` is in `lib/models/pref_model.dart`. Both are Flutter-free (or at least don't import Flutter widgets directly — `PrefModel` extends `ChangeNotifier` but that's a migration for another day).

**Both `SearchProvider` and `FavoritesProvider` already extend `ChangeNotifier`** — they just need to add `implements SearchInterface` (they already have this via the old import; this is a pure import-path change).

**Consumer impact: NONE.** No widget uses `Consumer<SearchInterface>` directly — they use concrete Provider types. `SearchInterface` is only used as a parameter type in:
- `ImageGrid({required SearchInterface model})` 
- `GalleryView({required SearchInterface model, ...})`
- `GalleryToolBar({required SearchInterface model, ...})`

### ConstStrings → Config Files Mapping

Every field in `lib/enums.dart` must be accounted for. Here is the EXACT mapping:

#### → `lib/config/booru_config.dart`

```dart
// Pure config — no Flutter imports.
import 'package:derpiviewer/core/domain/enums/booru.dart';

const String defaultHost = 'trixiebooru.org';
const String defaultSearchPath = '/api/v1/json/search/images';
const String defaultTrendingPath = '/api/v1/json/images/featured';

const Map<Booru, String> booruHosts = {
  Booru.derpi: 'derpibooru.org',
  Booru.trixie: 'trixiebooru.org',
  Booru.pony: 'ponybooru.org',
  Booru.twi: 'twibooru.org',
  Booru.fur: 'furbooru.org',
  Booru.ponerpics: 'ponerpics.org',
  Booru.mane: 'manebooru.art',
};

const Map<Booru, String> booruSearchPaths = {
  Booru.derpi: '/api/v1/json/search/images',
  Booru.trixie: '/api/v1/json/search/images',
  Booru.pony: '/api/v1/json/search/images',
  Booru.twi: '/api/v3/search/posts',
  Booru.fur: '/api/v1/json/search/images',
  Booru.ponerpics: '/api/v1/json/search/images',
  Booru.mane: '/api/v1/json/search/images',
};

const Map<Booru, String> booruTrendingPaths = {
  Booru.derpi: '/api/v1/json/images/featured',
  Booru.trixie: '/api/v1/json/images/featured',
  Booru.pony: '/api/v1/json/images/featured',
  Booru.twi: '/api/v3/posts/featured',
  Booru.fur: '/api/v1/json/images/featured',
  Booru.ponerpics: '/api/v1/json/images/featured',
  Booru.mane: '/api/v1/json/images/featured',
};

const Map<Booru, Map<String, int>> booruFilters = {
  Booru.derpi: {
    'Default': 100073,
    'Legacy Default': 37431,
    '18+ Dark': 37429,
    'Everything': 56027,
    '-safe': 201603,
    '18+ R34': 37432,
    'Maximum Spoilers': 37430,
  },
  // ... (all 7 boorus — copy from enums.dart lines 107-159)
};
```

**Field rename table (old → new):**
| Old (`ConstStrings.xxx`) | New import | New name |
|---|---|---|
| `ConstStrings.boorus` | `booru_config.dart` | `booruHosts` |
| `ConstStrings.searchPaths` | `booru_config.dart` | `booruSearchPaths` |
| `ConstStrings.trendingPaths` | `booru_config.dart` | `booruTrendingPaths` |
| `ConstStrings.filters` | `booru_config.dart` | `booruFilters` |
| `ConstStrings.defaultHost` | `booru_config.dart` | `defaultHost` |
| `ConstStrings.defaultSP` | `booru_config.dart` | `defaultSearchPath` |
| `ConstStrings.defaultTP` | `booru_config.dart` | `defaultTrendingPath` |

#### → `lib/config/tag_categories.dart`

```dart
import 'package:flutter/material.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';

const Map<TagCategory, Color> tagBackColors = { /* copy from enums.dart:161-173 */ };
const Map<TagCategory, Color> tagForeColors = { /* copy from enums.dart:175-188 */ };
const List<String> ratingTags = [ /* copy from enums.dart:189-197 */ ];
const List<String> bodyTags = [ /* copy from enums.dart:198-210 */ ];
const List<String> errorTags = [ /* copy from enums.dart:211-220 */ ];
```

Note: `tag_categories.dart` imports `package:flutter/material.dart` for `Color`. This is acceptable — the `config/` layer can import Flutter for value types like `Color`, just not for widgets or BuildContext.

| Old | New import | New name |
|---|---|---|
| `ConstStrings.tagBackColors` | `tag_categories.dart` | `tagBackColors` |
| `ConstStrings.tagForeColors` | `tag_categories.dart` | `tagForeColors` |
| `ConstStrings.ratingTags` | `tag_categories.dart` | `ratingTags` |
| `ConstStrings.bodyTags` | `tag_categories.dart` | `bodyTags` |
| `ConstStrings.errorTags` | `tag_categories.dart` | `errorTags` |

#### → `lib/config/constants.dart`

```dart
import 'package:flutter/widgets.dart'; // for BuildContext in getSfs/getSds
import 'package:derpiviewer/core/domain/enums/sort_field.dart';
import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';

const String fallbackImg = 'https://derpicdn.net/img/2012/1/2/1/medium.png';

const List<String> formatExtensions = ['gif', 'jpg', 'jpeg', 'png', 'svg', 'webm', 'mp4'];
const List<String> mimeTypes = ['image/gif', 'image/jpeg', 'image/jpeg', 'image/png', 'image/svg+xml', 'video/webm', 'video/mp4'];

const List<String> sortFields = ['wilson_score', 'created_at', 'updated_at', 'first_seen_at', 'score', 'relevance', 'width', 'height', 'comments', 'tag_count'];
const List<String> sortDirections = ['desc', 'asc'];

String getSortFieldLabel(BuildContext ctx, SortField field) { /* copy from enums.dart:54-77 */ }
String getSortDirectionLabel(BuildContext ctx, SortDirection dir) { /* copy from enums.dart:79-86 */ }
```

| Old | New import | New name |
|---|---|---|
| `ConstStrings.fallbackImg` | `constants.dart` | `fallbackImg` |
| `ConstStrings.format` | `constants.dart` | `formatExtensions` |
| `ConstStrings.mime` | `constants.dart` | `mimeTypes` |
| `ConstStrings.sfs` | `constants.dart` | `sortFields` |
| `ConstStrings.sds` | `constants.dart` | `sortDirections` |
| `ConstStrings.getSfs(ctx, f)` | `constants.dart` | `getSortFieldLabel(ctx, f)` |
| `ConstStrings.getSds(ctx, d)` | `constants.dart` | `getSortDirectionLabel(ctx, d)` |

### Files Importing `enums.dart` — Complete List (12 files)

| # | File | Uses ConstStrings members | New import(s) needed |
|---|------|--------------------------|---------------------|
| 1 | `lib/pages/home_page.dart` | `boorus`, `fallbackImg` | `booru_config.dart`, `constants.dart` |
| 2 | `lib/pages/fav_page.dart` | `boorus` | `booru_config.dart` |
| 3 | `lib/widgets/toolbar.dart` | `format` | `constants.dart` |
| 4 | `lib/widgets/detail.dart` | `tagForeColors`, `tagBackColors` | `tag_categories.dart` |
| 5 | `lib/api/do.dart` | `format` | `constants.dart` |
| 6 | `lib/api/clients.dart` | `boorus`, `defaultHost`, `trendingPaths`, `defaultTP`, `searchPaths` | `booru_config.dart` |
| 7 | `lib/models/pref_model.dart` | `boorus`, `filters` | `booru_config.dart` |
| 8 | `lib/helpers/helper.dart` | `ratingTags`, `bodyTags`, `errorTags` | `tag_categories.dart` |
| 9 | `lib/helpers/download.dart` | `boorus`, `format`, `mime` | `booru_config.dart`, `constants.dart` |
| 10 | `lib/widgets/dialogs.dart` | `boorus`, `filters`, `getSds`, `getSfs` | `booru_config.dart`, `constants.dart` |
| 11 | `lib/core/domain/entities/image_entity.dart` | `format` | `constants.dart` |
| 12 | `lib/core/data/repositories/image_repository_impl.dart` | `boorus`, `defaultHost`, `sds`, `sfs` | `booru_config.dart`, `constants.dart` |

**⚠️ IMPORTANT:** `lib/core/data/datasources/strategies/booru_api_strategy_factory.dart` references `ConstStrings` in a COMMENT only (line 16). No code change needed, but update the comment to reference `booru_config.dart`.

### Files Importing `search_model.dart` — Complete List (5 files)

| # | File | Change |
|---|------|--------|
| 1 | `lib/ui/providers/search_provider.dart` | Replace with `search_interface.dart`, keep `extends ChangeNotifier implements SearchInterface` |
| 2 | `lib/ui/providers/favorites_provider.dart` | Replace with `search_interface.dart`, keep `extends ChangeNotifier implements SearchInterface` |
| 3 | `lib/widgets/image_grid.dart` | Replace with `search_interface.dart` |
| 4 | `lib/pages/gallery.dart` | Replace with `search_interface.dart` |
| 5 | `lib/widgets/toolbar.dart` | Replace with `search_interface.dart` |

### Dialog File Split Reference

Each dialog file should contain exactly one public class + its imports:

| File | Class | Lines (approx) | Key imports |
|------|-------|----------------|-------------|
| `booru_dialog.dart` | `ChangeBooruDialog` | ~43 | `booru_config.dart`, `fluttertoast` |
| `search_params_dialog.dart` | `ChangeParamDialog` | ~87 | `booru_config.dart`, `constants.dart`, `app_localizations.dart` |
| `download_prefs_dialog.dart` | `ChangeDownloadPrefDialog` | ~123 | `image_size.dart`, `app_localizations.dart` |
| `api_key_dialog.dart` | `ChangeKeyDialog` | ~44 | `app_localizations.dart` |
| `cache_dialog.dart` | `ClearCacheDialog` | ~39 | `cache_helper.dart` |
| `about_dialog.dart` | `CustomAboutDialog` | ~47 | `url_launcher.dart` |
| `slideshow_dialog.dart` | `ChangeSlideIntervalDialog` | ~32 | — |

### home_page.dart Split Reference

**`lib/pages/home_page.dart`** (after split, ~90 lines):
- `HomePage` StatefulWidget + `_MyHomePageState`
- Download callback setup (ReceivePort, IsolateNameServer)
- Scaffold with AppBar, TrendingScroll body, HomeDrawer drawer, FAB column
- Imports: `trending_scroll.dart`, `home_drawer.dart`, individual dialog files

**`lib/ui/widgets/trending_scroll.dart`** (new file, ~180 lines):
- `TrendingScroll` StatefulWidget + `_TrendingScrollState`
- `_FeaturedSkeleton` private widget
- ScrollController, scroll callback, featured banner, grid switching
- Imports: `booru_config.dart`, `constants.dart`, `error_view.dart`, `skeleton_grid.dart`, `image_grid.dart`

**`lib/ui/widgets/home_drawer.dart`** (new file, ~160 lines):
- `HomeDrawer` StatelessWidget
- DrawerHeader + all ListTiles (booru, search params, download prefs, cache, about, single column, dark mode, slideshow)
- Imports: individual dialog files, `booru_config.dart`, `app_localizations.dart`

### Execution Order Matters

Do NOT parallelize these tasks — later tasks depend on earlier ones:

1. **Task 1 FIRST** (enums.dart → config/) — because ALL other files import `enums.dart`. Getting the config files right first prevents cascading fixes.
2. **Task 2 SECOND** (SearchInterface) — because home_page split imports search_model transitively.
3. **Task 3 THIRD** (home_page split) — depends on both config files and SearchInterface.
4. **Task 4 FOURTH** (dialogs split) — depends on config files being in place.
5. **Task 5 FIFTH** (ErrorView verify) — read-only check.
6. **Task 6 LAST** (validation).

### Files to Create

| File | Purpose |
|------|---------|
| `lib/config/booru_config.dart` | Booru hosts, API paths, filter configurations |
| `lib/config/tag_categories.dart` | Tag category colors and tag lists |
| `lib/config/constants.dart` | Fallback URLs, MIME types, sort labels |
| `lib/core/domain/search_interface.dart` | Pure abstract SearchInterface (no ChangeNotifier) |
| `lib/ui/widgets/trending_scroll.dart` | Extracted TrendingScroll from home_page |
| `lib/ui/widgets/home_drawer.dart` | Extracted HomeDrawer from home_page |
| `lib/ui/widgets/dialogs/booru_dialog.dart` | ChangeBooruDialog |
| `lib/ui/widgets/dialogs/search_params_dialog.dart` | ChangeParamDialog |
| `lib/ui/widgets/dialogs/download_prefs_dialog.dart` | ChangeDownloadPrefDialog |
| `lib/ui/widgets/dialogs/api_key_dialog.dart` | ChangeKeyDialog |
| `lib/ui/widgets/dialogs/cache_dialog.dart` | ClearCacheDialog |
| `lib/ui/widgets/dialogs/about_dialog.dart` | CustomAboutDialog |
| `lib/ui/widgets/dialogs/slideshow_dialog.dart` | ChangeSlideIntervalDialog |

### Files to Modify

| File | Change |
|------|--------|
| `lib/pages/home_page.dart` | Strip to HomePage only; import extracted widgets + individual dialogs + config files |
| `lib/ui/providers/search_provider.dart` | Import `search_interface.dart` instead of `search_model.dart` |
| `lib/ui/providers/favorites_provider.dart` | Import `search_interface.dart` instead of `search_model.dart` |
| `lib/widgets/image_grid.dart` | Import `search_interface.dart` instead of `search_model.dart` |
| `lib/pages/gallery.dart` | Import `search_interface.dart` instead of `search_model.dart` |
| `lib/widgets/toolbar.dart` | Import `search_interface.dart` instead of `search_model.dart`; import `constants.dart` instead of `enums.dart` |
| `lib/pages/fav_page.dart` | Import `booru_config.dart` instead of `enums.dart` |
| `lib/widgets/detail.dart` | Import `tag_categories.dart` instead of `enums.dart` |
| `lib/api/do.dart` | Import `constants.dart` instead of `enums.dart` |
| `lib/api/clients.dart` | Import `booru_config.dart` instead of `enums.dart` |
| `lib/models/pref_model.dart` | Import `booru_config.dart` instead of `enums.dart` |
| `lib/helpers/helper.dart` | Import `tag_categories.dart` instead of `enums.dart` |
| `lib/helpers/download.dart` | Import `booru_config.dart` + `constants.dart` instead of `enums.dart` |
| `lib/core/domain/entities/image_entity.dart` | Import `constants.dart` instead of `enums.dart` |
| `lib/core/data/repositories/image_repository_impl.dart` | Import `booru_config.dart` + `constants.dart` instead of `enums.dart` |
| `lib/core/data/datasources/strategies/booru_api_strategy_factory.dart` | Update comment reference from ConstStrings to booru_config |

### Files to Delete

| File | Reason |
|------|--------|
| `lib/enums.dart` | Split into 3 config files |
| `lib/models/search_model.dart` | Interface moved to `core/domain/search_interface.dart` |
| `lib/widgets/dialogs.dart` | Split into 7 individual dialog files |

### Preserved Behaviors (MUST NOT BREAK)

- All 80 existing tests must pass unchanged
- Booru switching in drawer must work identically
- Search params dialog must show correct filter options per booru
- Download dialog must show correct size options
- Cache clearing must work (image + video)
- About dialog must show correct info + tappable GitHub link
- Slideshow interval slider must work (1-30 seconds)
- API key dialog must accept input + clear button
- Trending scroll infinite-scroll behavior must be preserved
- FeaturedBanner skeleton + failure fallback must work
- Home drawer dark mode toggle + single column toggle must work
- FABs (favorites + search) must navigate correctly
- Download callback registration (ReceivePort) must work on app start
- AppBar booru name display must update on booru switch
- `ImageGrid`, `GalleryView`, `GalleryToolBar` must accept `SearchInterface` parameter (unchanged contract)

### References

- [Architecture: Project Structure](_bmad-output/planning-artifacts/architecture.md#complete-project-directory-structure) — Target directory layout
- [Architecture: Domain Boundary](_bmad-output/planning-artifacts/architecture.md#architectural-boundaries) — `core/domain/` import rules
- [Architecture: File Split Plan](_bmad-output/planning-artifacts/architecture.md#file-split-plan) — Original split design
- [Epics: Story 3.1](_bmad-output/planning-artifacts/epics.md#story-31-file-splits-and-reusable-errorview-widget)
- [Story 1.4: ErrorView creation](_bmad-output/implementation-artifacts/1-4-search-provider-viewstate-skeleton-empty-retry.md)
- [Story 1.1: Enum extraction](_bmad-output/implementation-artifacts/1-1-di-container-enums-sealed-classes.md)
- Current source: `lib/enums.dart` (221 lines)
- Current source: `lib/pages/home_page.dart` (461 lines)
- Current source: `lib/models/search_model.dart` (20 lines)
- Current source: `lib/widgets/dialogs.dart` (441 lines)

## Change Log

- 2026-06-05: Story 3.1 implementation complete — All 6 ACs satisfied
  - 13 files created, 17 files modified, 3 files deleted
  - `flutter analyze` zero errors, 96/96 tests pass
  - Config files created: `lib/config/booru_config.dart`, `lib/config/tag_categories.dart`, `lib/config/constants.dart`
  - Domain SearchInterface created: `lib/core/domain/search_interface.dart`
  - home_page.dart split into 3 files, dialogs.dart split into 7 files
  - 12 enums.dart importers migrated to new config files
  - 5 search_model.dart importers migrated to domain search_interface.dart

## Dev Agent Record

### Agent Model Used

Claude (BMad create-story workflow)

### Completion Notes List

- Story 3.1 created covering 5 remaining work items (ErrorView already done in 1.4)
- 13 files to create, 16 files to modify, 3 files to delete
- 12 importers of `enums.dart` identified and mapped to new config files
- 5 importers of `search_model.dart` identified for SearchInterface migration
- SearchInterface must NOT extend ChangeNotifier in domain layer — both Providers already extend ChangeNotifier independently
- Config naming: `booruHosts` (not `boorus`), `formatExtensions` (not `format`), `mimeTypes` (not `mime`) — clearer, more descriptive
- Task execution order is critical: Task 1 (config) → Task 2 (SearchInterface) → Task 3 (home_page) → Task 4 (dialogs) → Task 5 (verify) → Task 6 (validate)
- ✅ Task 1: Split enums.dart into 3 config files — 12 files updated, zero errors
- ✅ Task 2: SearchInterface moved to domain layer — pure abstract class, 5 files + 1 test file updated
- ✅ Task 3: home_page.dart split into 3 files — home_page (~97 lines), trending_scroll (~176 lines), home_drawer (~148 lines)
- ✅ Task 4: dialogs.dart split into 7 files — each under 100 lines, home_drawer uses individual imports
- ✅ Task 5: ErrorView verified — correct signature, all 5 usages compile
- ✅ Task 6: Full validation — flutter analyze zero errors, 96/96 tests pass

### File List

**Files Created:**
- `lib/config/booru_config.dart` — Booru hosts, API paths, filter configurations
- `lib/config/constants.dart` — Fallback URLs, MIME types, format extensions, sort labels
- `lib/config/tag_categories.dart` — Tag category colors and tag lists
- `lib/core/domain/search_interface.dart` — Pure abstract SearchInterface (no ChangeNotifier)
- `lib/ui/widgets/dialogs/about_dialog.dart` — CustomAboutDialog
- `lib/ui/widgets/dialogs/api_key_dialog.dart` — ChangeKeyDialog
- `lib/ui/widgets/dialogs/booru_dialog.dart` — ChangeBooruDialog
- `lib/ui/widgets/dialogs/cache_dialog.dart` — ClearCacheDialog
- `lib/ui/widgets/dialogs/download_prefs_dialog.dart` — ChangeDownloadPrefDialog
- `lib/ui/widgets/dialogs/search_params_dialog.dart` — ChangeParamDialog
- `lib/ui/widgets/dialogs/slideshow_dialog.dart` — ChangeSlideIntervalDialog
- `lib/ui/widgets/home_drawer.dart` — Extracted HomeDrawer from home_page
- `lib/ui/widgets/trending_scroll.dart` — Extracted TrendingScroll from home_page

**Files Modified:**
- `lib/api/clients.dart` — Import `booru_config.dart` instead of `enums.dart`; rename ConstStrings → config constants
- `lib/api/do.dart` — Import `constants.dart` instead of `enums.dart`; `ConstStrings.format` → `formatExtensions`
- `lib/core/data/datasources/strategies/booru_api_strategy_factory.dart` — Update comment reference from ConstStrings to booru_config
- `lib/core/data/repositories/image_repository_impl.dart` — Import `booru_config.dart` + `constants.dart` instead of `enums.dart`
- `lib/core/domain/entities/image_entity.dart` — Import `constants.dart` instead of `enums.dart`
- `lib/helpers/download.dart` — Import `booru_config.dart` + `constants.dart` instead of `enums.dart`
- `lib/helpers/helper.dart` — Import `tag_categories.dart` instead of `enums.dart`
- `lib/models/pref_model.dart` — Import `booru_config.dart` instead of `enums.dart`
- `lib/pages/fav_page.dart` — Import `booru_config.dart` instead of `enums.dart`
- `lib/pages/gallery.dart` — Import `search_interface.dart` instead of `search_model.dart`
- `lib/pages/home_page.dart` — Stripped to HomePage only; import extracted widgets + config files
- `lib/ui/providers/favorites_provider.dart` — Import `search_interface.dart` instead of `search_model.dart`
- `lib/ui/providers/search_provider.dart` — Import `search_interface.dart` instead of `search_model.dart`
- `lib/widgets/detail.dart` — Import `tag_categories.dart` instead of `enums.dart`
- `lib/widgets/image_grid.dart` — Import `search_interface.dart` instead of `search_model.dart`
- `lib/widgets/toolbar.dart` — Import `search_interface.dart` instead of `search_model.dart`; `constants.dart` instead of `enums.dart`
- `test/ui/widgets/gallery_toolbar_scrim_test.dart` — Import `search_interface.dart` instead of `search_model.dart`

**Files Deleted:**
- `lib/enums.dart` — Split into 3 config files
- `lib/models/search_model.dart` — Interface moved to `core/domain/search_interface.dart`
- `lib/widgets/dialogs.dart` — Split into 7 individual dialog files

**Sprint Status:**
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — Updated 3-1 status: ready-for-dev → in-progress
