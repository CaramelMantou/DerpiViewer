# Derpiviewer - Source Tree Analysis

**Date:** 2026-06-04

## Overview

Derpiviewer follows Flutter's standard project layout. All application code resides in `lib/`, organized into a flat structure of ~20 Dart files across 6 directories. No deep nesting, no monorepo parts.

## Complete Directory Structure

```
derpiviewer/
├── android/                       # Android platform (Gradle build, manifests)
├── build/                         # Build output (not source-controlled)
├── lib/                           # *Application source root*
│   ├── main.dart                  # App entry point & Provider wiring
│   ├── enums.dart                 # All enums + ConstStrings config class
│   ├── api/                       # API layer
│   │   ├── clients.dart           # BasePhilomenaClient singleton
│   │   └── do.dart                # ImageResponse DTO + PrefParams
│   ├── helpers/                   # Infrastructure utilities
│   │   ├── connect.dart           # DioClient + getData() HTTP function
│   │   ├── db.dart                # DbHelper SQLite (static methods)
│   │   ├── helper.dart            # Clipboard + tag category utilities
│   │   ├── cache_helper.dart      # ImageCacheManager + VideoCacheManager
│   │   ├── download.dart          # DownloadHelper (download + share)
│   │   └── philomena_api.dart     # (empty placeholder)
│   ├── models/                    # State management (ChangeNotifiers)
│   │   ├── pref_model.dart        # PrefModel: user preferences
│   │   ├── search_model.dart      # SearchModel + SearchInterface abstract class
│   │   ├── trending_model.dart    # TrendingModel extends SearchModel
│   │   └── fav_model.dart         # FavModel implements SearchInterface
│   ├── pages/                     # Top-level route pages
│   │   ├── home_page.dart         # HomePage + TrendingScroll + HomeDrawer
│   │   ├── search_page.dart       # SearchPage: query input
│   │   ├── result_page.dart       # ResultPage + ResultScroll
│   │   ├── fav_page.dart          # FavouritePage + FavouriteScroll
│   │   └── gallery.dart           # GalleryView: full-screen viewer
│   ├── widgets/                   # Reusable UI components
│   │   ├── image_grid.dart        # ImageGrid + ThumbHero
│   │   ├── detail.dart            # DetailSheet: metadata bottom sheet
│   │   ├── dialogs.dart           # 7 dialog widgets
│   │   ├── toolbar.dart           # GalleryToolBar + ToolbarController
│   │   ├── icons.dart             # FavIcon + FavIconController
│   │   └── video_view.dart        # VideoView: video player wrapper
│   ├── style/                     # Visual theming
│   │   └── theme.dart             # AppTheme (light + dark ThemeData)
│   └── l10n/                      # Internationalization
│       ├── app_localizations.dart # Generated localizations delegate
│       ├── app_localizations_en.dart
│       ├── app_localizations_zh.dart
│       ├── app_en.arb             # English strings
│       └── app_zh.arb             # Chinese strings
├── assets/                        # App icons (derpy.png)
├── docs/                          # Generated documentation (this file)
├── philomena_api.md               # API field reference
├── README.md                      # Project readme
├── pubspec.yaml                   # Flutter package manifest
├── pubspec.lock                   # Dependency lockfile
└── analysis_options.yaml          # Dart lint rules
```

## Critical Directories

### `lib/api/`
**Purpose:** External API communication layer.
**Contains:** HTTP client singleton, data transfer objects.
**Note:** Currently thin — only 2 files. The API client directly returns DTOs used by models, with no repository abstraction.

### `lib/models/`
**Purpose:** State management via Provider + ChangeNotifier pattern.
**Contains:** 4 models covering preferences, search, trending, favorites.
**Note:** Models contain both business logic (pagination, fetching) AND Flutter-specific notification (`ChangeNotifier`). `SearchInterface` abstract class lives here but serves the Widget layer.

### `lib/pages/`
**Purpose:** Top-level navigable screens.
**Contains:** 5 page files. `home_page.dart` is the largest (323 lines, 3 widgets).
**Note:** Pages directly import and call models, API client, and DB helpers. No intermediary service layer.

### `lib/widgets/`
**Purpose:** Reusable UI components.
**Contains:** 6 widget files. Grid, gallery toolbar, detail sheet, dialogs, icons, video player.
**Note:** Widgets receive `SearchInterface` for loose coupling to models. Dialogs directly `Provider.of<T>()` which couples them to the Provider tree.

### `lib/helpers/`
**Purpose:** Infrastructure utilities (HTTP, DB, cache, download).
**Contains:** 6 files, one is placeholder.
**Note:** All helpers use static methods or singletons. No dependency injection.

### `lib/l10n/`
**Purpose:** Chinese + English localization.
**Contains:** ARB source files + generated Dart delegates.
**Integration:** `AppLocalizations.of(context)!` throughout UI.

### `lib/style/`
**Purpose:** Material theme definitions.
**Contains:** Light and dark ThemeData.

## Entry Points

- **Main Entry:** `lib/main.dart:13` — `main()` function
  - Initializes `FlutterDownloader`
  - Initializes `DbHelper.initDB()`
  - Sets up `MultiProvider` with 4 ChangeNotifier providers
  - Launches `DVApp` (MaterialApp wrapper)

## File Organization Patterns

- **Flat directory structure** — no deep nesting; each directory has a single layer of files
- **No barrel files** — no `index.dart` exports; all imports reference specific file paths
- **Mixed abstraction levels** — `api/do.dart` contains both `ImageResponse` (DTO) and `PrefParams` (value object); `models/search_model.dart` contains both `SearchInterface` (abstraction) and `SearchModel` (implementation)
- **No test files in lib/** — test directory exists (`test/`) via Flutter template but contains no active tests

## Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Flutter package manifest: dependencies, assets, build config |
| `pubspec.lock` | Pinned dependency versions |
| `analysis_options.yaml` | Dart static analysis (lint) rules |
| `android/app/build.gradle` | Android build config: minSdk, targetSdk, signing |

## Dependencies Between Directories

```
pages/ ──────▶ models/ ──────▶ api/
  │               │               │
  │               └──────▶ helpers/ (db, connect)
  │                           │
  └──────▶ widgets/ ────────┘
              │
              └──────▶ helpers/ (cache, download, helper)
              │
pages/ ──────▶ helpers/ (db, download, cache)
              │
ALL ────────▶ enums.dart (ConstStrings, enums)
ALL ────────▶ l10n/ (localization)
```

**Key observation:** `enums.dart` is the most heavily imported file — every layer depends on it, making it the single point of coupling.

---

_Generated using BMAD Method `document-project` workflow_
