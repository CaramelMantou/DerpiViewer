# Derpiviewer - Component Inventory

**Date:** 2026-06-04

## Overview

The Flutter UI layer is organized into pages, widgets, and dialogs, with Provider-based state management binding them to models.

## Architectural Pattern

**Provider + ChangeNotifier (MVVM-like)**

```
┌──────────────────────────────────────────────────┐
│  UI Layer (Pages / Widgets)                      │
│  - Reads state via Consumer<T> / Provider.of<T>  │
│  - Triggers actions on models                    │
├──────────────────────────────────────────────────┤
│  State Layer (Models as ChangeNotifiers)         │
│  - PrefModel: app-wide preferences               │
│  - SearchModel: search results & pagination      │
│  - TrendingModel extends SearchModel: trending   │
│  - FavModel: local favorites                     │
├──────────────────────────────────────────────────┤
│  Data Layer (API Client / DB Helper)             │
│  - BasePhilomenaClient: HTTP singleton           │
│  - DbHelper: SQLite static methods               │
└──────────────────────────────────────────────────┘
```

Provider setup in `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<PrefModel>(...),
    ChangeNotifierProxyProvider<PrefModel, TrendingModel>(...),
    ChangeNotifierProxyProvider<PrefModel, SearchModel>(...),
    ChangeNotifierProxyProvider<PrefModel, FavModel>(...),
  ],
)
```

## Pages

### HomePage
**File:** `lib/pages/home_page.dart:23`
**Route:** `/` (default)
**Purpose:** Main entry screen with featured image, trending grid, navigation drawer, and FABs for favorites/search.
**State:** Consumes TrendingModel, PrefModel, FavModel
**Key behaviors:**
- Initializes downloader isolate port for background download callbacks
- Save preferences and close DB on back press (`WillPopScope`)
- Hosts `TrendingScroll` and `HomeDrawer` sub-widgets

### TrendingScroll
**File:** `lib/pages/home_page.dart:108`
**Purpose:** Displays featured image (tappable → search by ID) + infinite-scroll trending image grid.
**State:** Consumes TrendingModel via Consumer

### HomeDrawer
**File:** `lib/pages/home_page.dart:166`
**Purpose:** Navigation drawer with booru switcher, search params, size prefs, cache management, dark mode, slideshow interval, about dialog.

### SearchPage
**File:** `lib/pages/search_page.dart:7`
**Route:** pushed via Navigator
**Purpose:** Search input with history (via `InputHistoryTextField`). On submit → navigates to ResultPage.
**Parameters:** `initQuery` (optional, pre-fills search query)

### ResultPage
**File:** `lib/pages/result_page.dart:6`
**Route:** pushed from SearchPage
**Purpose:** Displays search results in an infinite-scroll grid.
**Parameters:** `query` (search term)
**State:** Consumes SearchModel

### FavouritePage
**File:** `lib/pages/fav_page.dart:10`
**Route:** pushed from HomePage FAB
**Purpose:** Displays locally-favorited images in an infinite-scroll grid.
**State:** Consumes FavModel

### GalleryView
**File:** `lib/pages/gallery.dart:17`
**Route:** pushed from ImageGrid on thumbnail tap
**Purpose:** Full-screen photo gallery with zoom, swipe navigation, toolbar overlay, and slideshow mode.
**Parameters:** `model` (SearchInterface), `startIndex` (int)
**State:** Reads PrefModel for size/slideshow preferences

## Widgets

### ImageGrid
**File:** `lib/widgets/image_grid.dart:10`
**Purpose:** SliverGrid displaying image thumbnails. Supports single/dual column layout based on `PrefModel.isSingleColumn`.
**Parameters:** `model` (SearchInterface)
**Key behavior:** Tapping a thumbnail navigates to GalleryView.

### ThumbHero
**File:** `lib/widgets/image_grid.dart:54`
**Purpose:** Individual thumbnail with Hero animation tag. Uses CachedNetworkImage.
**Parameters:** `photo` (String URL), `idTag` (int), `onTap` (VoidCallback)

### GalleryToolBar
**File:** `lib/widgets/toolbar.dart:11`
**Purpose:** Overlay toolbar on GalleryView: favorite toggle, download, share (image or link), info/details.
**Parameters:** `model` (SearchInterface), `index` (int), `controller` (ToolbarController)

### ToolbarController
**File:** `lib/widgets/toolbar.dart:207`
**Purpose:** ValueNotifier<int> tracking current gallery page index. Enables reactive toolbar updates on page changes.

### DetailSheet
**File:** `lib/widgets/detail.dart:13`
**Purpose:** Bottom sheet showing image metadata: ID, uploader, date, description (Markdown), up/down/fave/comment counts, and tag chips with category-colored backgrounds.
**Parameters:** `image` (ImageResponse)

### VideoView
**File:** `lib/widgets/video_view.dart`
**Purpose:** Chewie-wrapped video player widget. Used in GalleryView for webm/mp4 content.

### FavIcon
**File:** `lib/widgets/icons.dart`
**Purpose:** Animated heart icon for favorite toggle, driven by FavIconController.

## Dialogs

**File:** `lib/widgets/dialogs.dart`

| Dialog | Purpose |
|--------|---------|
| ChangeBooruDialog | SimpleDialog listing all boorus; tapping changes host |
| ChangeParamDialog | DropdownMenus for sort direction, sort field, and filter selection |
| ChangeDownloadPrefDialog | DropdownMenus for image preview, video preview, download, and share sizes |
| ChangeKeyDialog | TextField for API key entry |
| ClearCacheDialog | Options to clear image cache, video cache, or both |
| CustomAboutDialog | App info with author and GitHub link |
| ChangeSlideIntervalDialog | Slider for slideshow interval (1-30 seconds) |

## Theme

**File:** `lib/style/theme.dart`
**Purpose:** Defines `AppTheme.defaultTheme` and `AppTheme.darkTheme` — light and dark Material themes. Switched via `PrefModel.isDarkMode`.

## Localization

**Directory:** `lib/l10n/`
**Files:** `app_localizations.dart` (generated), `app_en.arb`, `app_zh.arb`
**Languages:** English, Chinese (Simplified)
**Usage:** `AppLocalizations.of(context)!` pattern throughout UI

## Abstract Interface

### SearchInterface
**File:** `lib/models/search_model.dart:157`
**Purpose:** Abstract contract used by `ImageGrid`, `GalleryView`, `GalleryToolBar`, and `DetailSheet` to work with any image list model.
**Implementations:** `SearchModel`, `TrendingModel` (via inheritance), `FavModel`

```dart
abstract class SearchInterface extends ChangeNotifier {
  int getItemCount();
  int getItemID(int index);
  String getItemUrl(int index, Size size);
  ImageResponse getItem(int index);
  ContentFormat getItemFormat(int index);
  String getItemMediumThumbUrl(int index);
  String getItemThumbUrl(int index);
  void fetchMore({bool refresh});
  Booru getBooru();
  PrefModel getPref();
}
```

## Known Issues

1. **home_page.dart is too large** — contains 3 distinct widgets (HomePage, TrendingScroll, HomeDrawer) in one file; should be split
2. **SearchInterface lives in search_model.dart** — interface and one implementation in same file violates separation of concerns
3. **Dialogs directly access PrefModel** — coupling to Provider context makes dialogs hard to reuse or test in isolation
4. **No widget tests** — zero widget or integration tests exist
5. **BuildContext passed to ConstStrings for l10n** — `ConstStrings.getSfs(ctx, field)` mixes config constants with UI concerns
6. **Inline bottom sheet construction** — GalleryToolBar builds share/info bottom sheets inline rather than delegating to dedicated widgets
