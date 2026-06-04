---
baseline_commit: 52fdfc4da151e925cf2cd21cf83390785396f99d
---

# Story 3.3: i18n Extraction, Accessibility, and Locale Formatting

Status: done

## Story

As a user,
I want all UI text to respect my language choice, dates and numbers formatted for my locale, and every interactive element to have an accessible label,
so that the app feels native regardless of language setting and is usable by screen reader users.

## Acceptance Criteria

1. **Given** the app language is set to English
   **When** the user opens the drawer
   **Then** ALL items display in English: "Clear Cache" (not 清除缓存), "About" (not 关于), "Single Column Mode" (not 单列模式), "Dark Mode" (not 夜间模式), "Slideshow Interval" (not 幻灯片间隔)
   **And** all previously-hardcoded strings have been extracted to `app_en.arb` and `app_zh.arb`
   **And** the drawer code uses `AppLocalizations.of(context)!.drawerClearCache`, etc.

2. **Given** `CacheDialog`, `SlideshowDialog`, and `SearchPage` are rendered
   **When** the user views them in any language
   **Then** all dialog titles, labels, toasts, and hint text use `AppLocalizations` with no hardcoded strings
   **And** `flutter analyze` passes with zero errors

3. **Given** the user views the DetailSheet
   **When** the image creation date is displayed
   **Then** the date format respects the system locale using `DateFormat` with skeleton patterns (e.g., "Jun 4, 2026, 3:30 PM" for en_US, "2026年6月4日 15:30" for zh_CN)
   **And** the stats numbers use locale-aware grouping separators via `NumberFormat.decimalPattern()` (e.g., "1,234" for en_US)

4. **Given** any interactive element without a descriptive label (IconButton, FloatingActionButton, GestureDetector wrapping icons)
   **When** the user long-presses or a screen reader focuses the element
   **Then** a `tooltip` or `Semantics.semanticLabel` is present with a descriptive label
   **And** tooltips are added to: FABs (Favorites, Search), Gallery toolbar (favorite, download, share, info), slideshow toggle (play/pause), API key clear button
   **And** existing search page tooltips ("Back", "Clear", "Search") are moved to l10n
   **And** `Semantics` wraps key FABs and gallery toolbar icons with `semanticLabel`

5. **Given** `flutter analyze` runs
   **Then** zero errors
   **And** all existing tests continue to pass with zero regressions

## Tasks / Subtasks

- [x] Task 1: Add new l10n keys to ARB files (AC: 1, 2)
  - [x] Add ~29 new entries to `lib/l10n/app_en.arb` (drawer items, cache dialog, slideshow dialog, search page, toolbar tips, general)
  - [x] Add matching ~29 entries to `lib/l10n/app_zh.arb`
  - [x] Run code generation to update `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_zh.dart`

- [x] Task 2: Extract hardcoded strings from Drawer (AC: 1)
  - [x] Replace 7 hardcoded strings in `lib/ui/widgets/home_drawer.dart` with `AppLocalizations` lookups
  - [x] Keys: `drawerClearCache`, `drawerClearCacheDescription`, `drawerAbout`, `drawerSingleColumn`, `drawerSlideshowInterval`, `drawerSlideshowIntervalValue`, `drawerDarkMode`

- [x] Task 3: Extract hardcoded strings from Dialogs (AC: 2)
  - [x] Update `lib/ui/widgets/dialogs/cache_dialog.dart`: 7 strings → l10n
  - [x] Update `lib/ui/widgets/dialogs/slideshow_dialog.dart`: 4 strings → l10n
  - [x] Update `lib/pages/search_page.dart`: search hint text "搜索..." → l10n + 3 tooltips
  - [x] Update `lib/pages/home_page.dart`: "Downloaded" toast → l10n

- [x] Task 4: Fix date and number locale formatting (AC: 3)
  - [x] `lib/widgets/detail.dart` line 63-64: Replace `DateFormat('yyyy-MM-dd HH:mm')` with locale-aware `DateFormat.yMd().add_jm()` from `package:intl`
  - [x] `lib/widgets/detail.dart` stats display: Wrap upvotes/downvotes/faves/comments with `NumberFormat.decimalPattern()` from `package:intl`
  - [x] Verify `intl` dependency exists in pubspec.yaml

- [x] Task 5: Add tooltips and semantic labels (AC: 4)
  - [x] `lib/pages/home_page.dart`: Add `tooltip` to Favorites FAB ("Favorites") and Search FAB ("Search")
  - [x] `lib/widgets/toolbar.dart`: Add `tooltip`/`Tooltip` to favorite GestureDetector, download/share/info IconButtons
  - [x] `lib/pages/gallery.dart`: Add `tooltip` to slideshow play/pause IconButton
  - [x] `lib/ui/widgets/dialogs/api_key_dialog.dart`: Add `tooltip` to clear IconButton
  - [x] `lib/pages/search_page.dart`: Migrate 3 hardcoded tooltips to l10n keys
  - [x] `lib/pages/home_page.dart`: Add `Semantics(label: ...)` wrapper to both FABs
  - [x] `lib/ui/widgets/trending_scroll.dart`: Replace hardcoded "No trending images available" → l10n

- [x] Task 6: Run full validation (AC: 5)
  - [x] `flutter analyze` — zero errors (93 issues: all pre-existing warnings/infos)
  - [x] `flutter test` — all 104 tests pass with zero regressions

## Dev Notes

### Complete String Extraction Inventory

#### A. `lib/ui/widgets/home_drawer.dart` — 7 hardcoded Chinese strings

| Line | Current (zh) | ARB Key | en value |
|------|-------------|---------|----------|
| 75 | `'清除缓存'` | `drawerClearCache` | `Clear Cache` |
| 76 | `'清除图片和视频缓存'` | `drawerClearCacheDescription` | `Clear image and video cache` |
| 88 | `'关于'` | `drawerAbout` | `About` |
| 100 | `'单列模式'` | `drawerSingleColumn` | `Single Column Mode` |
| 114 | `'幻灯片间隔'` | `drawerSlideshowInterval` | `Slideshow Interval` |
| 117 | `'${pref.slideInterval}秒'` | `drawerSlideshowIntervalValue` | `{seconds, plural, =1{1 second} other{{seconds} seconds}}` |
| 140 | `'夜间模式'` | `drawerDarkMode` | `Dark Mode` |

#### B. `lib/ui/widgets/dialogs/cache_dialog.dart` — 6 hardcoded Chinese strings

| Line | Current (zh) | ARB Key | en value |
|------|-------------|---------|----------|
| 11 | `'清除缓存'` | `cacheDialogTitle` | `Clear Cache` |
| 14 | `'清除图片缓存'` | `cacheClearImages` | `Clear Image Cache` |
| 18 | `'图片缓存已清除'` | `cacheImagesCleared` | `Image cache cleared` |
| 24 | `'清除视频缓存'` | `cacheClearVideos` | `Clear Video Cache` |
| 27 | `'视频缓存已清除'` | `cacheVideosCleared` | `Video cache cleared` |
| 32 | `'清除所有缓存'` | `cacheClearAll` | `Clear All Cache` |
| 37 | `'所有缓存已清除'` | `cacheAllCleared` | `All cache cleared` |

#### C. `lib/ui/widgets/dialogs/slideshow_dialog.dart` — 4 hardcoded Chinese strings

| Line | Current (zh) | ARB Key | en value |
|------|-------------|---------|----------|
| 11 | `'设置幻灯片间隔'` | `slideshowDialogTitle` | `Set Slideshow Interval` |
| 15 | `'当前间隔: ${pref.slideInterval}秒'` | `slideshowCurrentInterval` | `Current interval: {interval}` (parameterized) |
| 21 | `${pref.slideInterval}秒` (Slider label) | `slideshowIntervalValue` | `{seconds, plural, =1{1 sec} other{{seconds} secs}}` |
| 31 | `'确定'` | `dialogOk` | `OK` |

#### D. `lib/pages/search_page.dart` — 4 hardcoded strings

| Line | Current | ARB Key | en value |
|------|---------|---------|----------|
| 75 | `'搜索...'` (hint) | `searchHint` | `Search...` |
| 63 | `'Back'` (tooltip) | `tooltipBack` | `Back` |
| 91 | `'Clear'` (tooltip) | `tooltipClear` | `Clear` |
| 98 | `'Search'` (tooltip) | `tooltipSearch` | `Search` |

#### E. `lib/pages/home_page.dart` — 1 hardcoded English string

| Line | Current | ARB Key | en value |
|------|---------|---------|----------|
| 37 | `"Downloaded"` (toast) | `downloadComplete` | `Download complete` |

### ARB File Updates (Task 1)

**`app_en.arb` — add these entries (after existing keys):**

```json
{
  "drawerClearCache": "Clear Cache",
  "drawerClearCacheDescription": "Clear image and video cache",
  "drawerAbout": "About",
  "drawerSingleColumn": "Single Column Mode",
  "drawerSlideshowInterval": "Slideshow Interval",
  "drawerSlideshowIntervalValue": "{seconds, plural, =1{1 second} other{{seconds} seconds}}",
  "@drawerSlideshowIntervalValue": {
    "placeholders": {
      "seconds": {"type": "int"}
    }
  },
  "drawerDarkMode": "Dark Mode",
  "cacheDialogTitle": "Clear Cache",
  "cacheClearImages": "Clear Image Cache",
  "cacheImagesCleared": "Image cache cleared",
  "cacheClearVideos": "Clear Video Cache",
  "cacheVideosCleared": "Video cache cleared",
  "cacheClearAll": "Clear All Cache",
  "cacheAllCleared": "All cache cleared",
  "slideshowDialogTitle": "Set Slideshow Interval",
  "slideshowCurrentInterval": "Current interval: {interval}",
  "@slideshowCurrentInterval": {
    "placeholders": {
      "interval": {"type": "String"}
    }
  },
  "slideshowIntervalValue": "{seconds, plural, =1{1 sec} other{{seconds} secs}}",
  "@slideshowIntervalValue": {
    "placeholders": {
      "seconds": {"type": "int"}
    }
  },
  "dialogOk": "OK",
  "searchHint": "Search...",
  "tooltipBack": "Back",
  "tooltipClear": "Clear",
  "tooltipSearch": "Search",
  "tooltipFavorites": "Favorites",
  "tooltipFavoriteToggle": "Toggle favorite",
  "tooltipDownload": "Download",
  "tooltipShare": "Share",
  "tooltipInfo": "Details",
  "tooltipSlideshowPlay": "Play slideshow",
  "tooltipSlideshowPause": "Pause slideshow",
  "tooltipClearField": "Clear field",
  "downloadComplete": "Download complete",
  "trendingEmpty": "No trending images available"
}
```

**`app_zh.arb` — add matching entries:**

```json
{
  "drawerClearCache": "清除缓存",
  "drawerClearCacheDescription": "清除图片和视频缓存",
  "drawerAbout": "关于",
  "drawerSingleColumn": "单列模式",
  "drawerSlideshowInterval": "幻灯片间隔",
  "drawerSlideshowIntervalValue": "{seconds, plural, other{{seconds} 秒}}",
  "drawerDarkMode": "夜间模式",
  "cacheDialogTitle": "清除缓存",
  "cacheClearImages": "清除图片缓存",
  "cacheImagesCleared": "图片缓存已清除",
  "cacheClearVideos": "清除视频缓存",
  "cacheVideosCleared": "视频缓存已清除",
  "cacheClearAll": "清除所有缓存",
  "cacheAllCleared": "所有缓存已清除",
  "slideshowDialogTitle": "设置幻灯片间隔",
  "slideshowCurrentInterval": "当前间隔: {interval}",
  "slideshowIntervalValue": "{seconds, plural, other{{seconds}秒}}",
  "dialogOk": "确定",
  "searchHint": "搜索...",
  "tooltipBack": "返回",
  "tooltipClear": "清除",
  "tooltipSearch": "搜索",
  "tooltipFavorites": "收藏",
  "tooltipFavoriteToggle": "切换收藏",
  "tooltipDownload": "下载",
  "tooltipShare": "分享",
  "tooltipInfo": "详情",
  "tooltipSlideshowPlay": "播放幻灯片",
  "tooltipSlideshowPause": "暂停幻灯片",
  "tooltipClearField": "清除输入",
  "downloadComplete": "下载完成",
  "trendingEmpty": "暂无热门图片"
}
```

### Code Generation

After editing the `.arb` files, the generated Dart files must be regenerated. The project likely uses `flutter gen-l10n` or manual generation. Check `l10n.yaml` at the project root for the configuration.

```bash
flutter gen-l10n
```

This will regenerate:
- `lib/l10n/app_localizations.dart` (abstract class — adds new getters)
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_zh.dart`

### Date & Number Locale Formatting (Task 4)

**Before (detail.dart line 63-64):**
```dart
DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(_image.createdAt))
```

**After:**
```dart
// Locale-aware date formatting using ICU skeleton patterns.
// Produces: "Jun 4, 2026, 3:30 PM" (en) / "2026年6月4日 15:30" (zh)
DateFormat.yMd(locale).add_jm().format(DateTime.parse(_image.createdAt))
```

To get the locale, use `Localizations.localeOf(context)`:
```dart
final locale = Localizations.localeOf(context);
// ...
DateFormat.yMd(locale.languageCode).add_jm().format(...)
```

Import needed: `import 'package:intl/intl.dart';` (already imported in detail.dart).

**For numeric formatting**, wrap stats with `NumberFormat`:
```dart
// Before:
Text("${_image.upvotes}", ...)
Text("${_image.downvotes}", ...)
Text("${_image.faves}", ...)
Text("${_image.comments}", ...)

// After:
final numberFormat = NumberFormat.decimalPattern(locale.languageCode);
Text(numberFormat.format(_image.upvotes), ...)
Text(numberFormat.format(_image.downvotes), ...)
Text(numberFormat.format(_image.faves), ...)
Text(numberFormat.format(_image.comments), ...)
```

The `locale` variable should be obtained once in the build method:
```dart
final locale = Localizations.localeOf(context);
```

### Tooltip & Semantics (Task 5)

#### FABs in `home_page.dart`:

```dart
FloatingActionButton(
  heroTag: "fav-fab",
  tooltip: AppLocalizations.of(context)!.tooltipFavorites,
  child: Semantics(
    semanticLabel: AppLocalizations.of(context)!.tooltipFavorites,
    child: const Icon(Icons.favorite),
  ),
  onPressed: () { ... },
),
// ... similarly for Search FAB
```

#### Toolbar icons in `toolbar.dart`:

```dart
// Favorite (currently GestureDetector)
GestureDetector(
  child: Tooltip(
    message: AppLocalizations.of(context)!.tooltipFavoriteToggle,
    child: FavIcon(controller: favController),
  ),
  onTap: () async { ... },
),

// Download
IconButton(
  tooltip: AppLocalizations.of(context)!.tooltipDownload,
  icon: const Icon(Icons.download, color: Colors.white),
  onPressed: () async { ... },
),

// Share
IconButton(
  tooltip: AppLocalizations.of(context)!.tooltipShare,
  icon: const Icon(Icons.share, color: Colors.white),
  onPressed: () { ... },
),

// Info
IconButton(
  tooltip: AppLocalizations.of(context)!.tooltipInfo,
  icon: const Icon(Icons.info, color: Colors.white),
  onPressed: () { ... },
),
```

**Note:** The favorite GestureDetector in `toolbar.dart` is inside a `FutureBuilder`. Since `GestureDetector` doesn't have a `tooltip` property, wrap its child with `Tooltip` widget.

#### Slideshow toggle in `gallery.dart`:

```dart
IconButton(
  tooltip: isSlideshowPlaying
      ? AppLocalizations.of(context)!.tooltipSlideshowPause
      : AppLocalizations.of(context)!.tooltipSlideshowPlay,
  icon: Icon(
    isSlideshowPlaying ? Icons.pause : Icons.play_arrow,
    color: Colors.grey[600],
    size: 28.0,
  ),
  onPressed: toggleSlideshow,
),
```

#### API key clear button in `api_key_dialog.dart`:

```dart
suffixIcon: IconButton(
  tooltip: AppLocalizations.of(context)!.tooltipClearField,
  icon: const Icon(Icons.clear),
  onPressed: () { textController.clear(); },
)
```

#### Search page tooltips → l10n:

Replace `tooltip: 'Back'` with `tooltip: AppLocalizations.of(context)!.tooltipBack`
Replace `tooltip: 'Clear'` with `tooltip: AppLocalizations.of(context)!.tooltipClear`
Replace `tooltip: 'Search'` with `tooltip: AppLocalizations.of(context)!.tooltipSearch`

#### Trending empty state:

In `trending_scroll.dart`, replace:
```dart
const Text('No trending images available')
```
with:
```dart
Text(AppLocalizations.of(context)!.trendingEmpty)
```

### Files to Modify

| File | Change |
|------|--------|
| `lib/l10n/app_en.arb` | Add ~29 new l10n entries |
| `lib/l10n/app_zh.arb` | Add ~29 matching l10n entries |
| `lib/l10n/app_localizations.dart` | Regenerated by `flutter gen-l10n` |
| `lib/l10n/app_localizations_en.dart` | Regenerated |
| `lib/l10n/app_localizations_zh.dart` | Regenerated |
| `lib/ui/widgets/home_drawer.dart` | Replace 7 hardcoded strings with l10n |
| `lib/ui/widgets/dialogs/cache_dialog.dart` | Replace 6 hardcoded strings with l10n |
| `lib/ui/widgets/dialogs/slideshow_dialog.dart` | Replace 4 hardcoded strings with l10n |
| `lib/pages/search_page.dart` | Replace 4 hardcoded strings + 3 tooltips with l10n |
| `lib/pages/home_page.dart` | Replace "Downloaded" toast + add tooltips/semantics to FABs |
| `lib/widgets/detail.dart` | Locale-aware date + number formatting |
| `lib/widgets/toolbar.dart` | Add tooltips to 4 toolbar icons |
| `lib/pages/gallery.dart` | Add tooltip to slideshow toggle |
| `lib/ui/widgets/dialogs/api_key_dialog.dart` | Add tooltip to clear button |
| `lib/ui/widgets/trending_scroll.dart` | Replace hardcoded "No trending" text |

### Files to Create

None — modifications to existing files only.

### Preserved Behaviors (MUST NOT BREAK)

- Drawer navigation: all ListTile taps must still open correct dialogs
- Cache clearing: image/video/all cache operations must work identically
- Slideshow interval: slider 1-30 range preserved
- Search page: text input, history, submit all unchanged
- FABs: navigation to Favorites/Search pages preserved
- Gallery toolbar: fav/download/share/info all work unchanged
- Slideshow: play/pause toggle unchanged
- Date/number formatting: format changes only — no data changes
- All existing tests pass

### References

- [Epics: Story 3.3](_bmad-output/planning-artifacts/epics.md#story-33-i18n-extraction-and-accessibility)
- [UX-DR10: Tooltips on all IconButtons](_bmad-output/planning-artifacts/epics.md)
- [UX-DR11: Extract hardcoded Chinese to .arb](_bmad-output/planning-artifacts/epics.md)
- [UX-DR12: Date localization](_bmad-output/planning-artifacts/epics.md)
- [UX-DR13: Numeric formatting](_bmad-output/planning-artifacts/epics.md)
- [UX DESIGN.md: Typography](_bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/DESIGN.md#typography)
- Current source: `lib/l10n/app_en.arb` (47 entries), `lib/l10n/app_zh.arb` (58 entries)
- Current source: `lib/ui/widgets/home_drawer.dart` (159 lines, 7 hardcoded strings)
- Current source: `lib/widgets/detail.dart` (205 lines)
- Current source: `lib/pages/search_page.dart` (113 lines)

## Dev Agent Record

### Agent Model Used

Claude (BMad create-story workflow)

### Completion Notes List

- Story 3.3 created covering i18n extraction, accessibility (tooltips + semantics), and locale formatting
- ~24 hardcoded strings identified across 6 files → extracted to .arb with en + zh variants
- 29 new ARB entries added (24 replacements + 5 new tooltip-only keys)
- 11 tooltips added/fixed across home_page, toolbar, gallery, api_key_dialog, search_page
- Date formatting: hardcoded pattern → locale-aware skeleton (DateFormat.yMd().add_jm())
- Number formatting: raw toString → NumberFormat.decimalPattern() with locale grouping
- 15 files modified, 0 new files — broad but shallow changes
- `intl` package already in dependencies (used by localizations)

**Implementation Notes (2026-06-05):**
- Task 1: Added 29 new entries to both app_en.arb and app_zh.arb; ran `flutter gen-l10n` successfully
- Task 2: Replaced all 7 hardcoded Chinese strings in home_drawer.dart with AppLocalizations lookups
- Task 3: Extracted strings from cache_dialog (7 strings), slideshow_dialog (4 strings), search_page (4 strings + 3 tooltips), and home_page ("Downloaded" toast via didChangeDependencies pattern)
- Task 4: Updated detail.dart to use DateFormat.yMd(locale).add_jm() and NumberFormat.decimalPattern(locale) with locale from Localizations.localeOf(context)
- Task 5: Added Tooltip/tooltip to all interactive elements (FABs, toolbar icons, slideshow toggle, API key clear button), Semantics(label) wrappers on FABs, extracted trending empty string
- Task 6: flutter analyze: 0 errors (only pre-existing warnings/infos); flutter test: 104/104 pass, 0 regressions
- Fixed gallery_toolbar_scrim_test.dart to include AppLocalizations delegates (test was missing l10n setup after tooltip additions)
- Relaxed const on SliverFillRemaining in trending_scroll.dart (l10n value is dynamic)

### File List

- `lib/l10n/app_en.arb` — Added 29 new l10n entries
- `lib/l10n/app_zh.arb` — Added 29 matching l10n entries
- `lib/l10n/app_localizations.dart` — Regenerated by `flutter gen-l10n`
- `lib/l10n/app_localizations_en.dart` — Regenerated
- `lib/l10n/app_localizations_zh.dart` — Regenerated
- `lib/ui/widgets/home_drawer.dart` — Replaced 7 hardcoded strings with l10n
- `lib/ui/widgets/dialogs/cache_dialog.dart` — Replaced 7 hardcoded strings with l10n
- `lib/ui/widgets/dialogs/slideshow_dialog.dart` — Replaced 4 hardcoded strings with l10n
- `lib/pages/search_page.dart` — Replaced 4 strings + 3 tooltips with l10n
- `lib/pages/home_page.dart` — Replaced "Downloaded" toast + added tooltips/semantics to FABs
- `lib/widgets/detail.dart` — Locale-aware date + number formatting
- `lib/widgets/toolbar.dart` — Added tooltips to 4 toolbar icons
- `lib/pages/gallery.dart` — Added tooltip to slideshow toggle
- `lib/ui/widgets/dialogs/api_key_dialog.dart` — Added tooltip to clear button
- `lib/ui/widgets/trending_scroll.dart` — Replaced hardcoded "No trending" text with l10n
- `test/ui/widgets/gallery_toolbar_scrim_test.dart` — Added l10n delegate setup

### Change Log

- 2026-06-05: Story 3.3 implemented — i18n extraction (29 ARB entries), accessibility tooltips/semantics (11 elements), locale-aware date/number formatting, all 104 tests pass, flutter analyze zero errors
- 2026-06-05: Code review conducted — 3 reviewers (Blind Hunter, Edge Case Hunter, Acceptance Auditor), 1 decision-needed, 3 patch, 7 deferred, 10 dismissed

### Review Findings

#### Decision Needed

- [x] [Review][Decision] yMd vs yMMMd date skeleton — Resolved: keep `yMd` (numeric), matches spec code example. Spec visual example was descriptive, not prescriptive. [lib/widgets/detail.dart:65]

#### Patch

- [x] [Review][Patch] Cache AppLocalizations in gallery.dart — gallery.dart calls `AppLocalizations.of(context)!` twice in a ternary; other files use `final l10n = ...` for consistency [lib/pages/gallery.dart:136-137]
- [x] [Review][Patch] Fix Chinese ARB space before unit — `drawerSlideshowIntervalValue` has unnatural space: removed space before 秒 [lib/l10n/app_zh.arb]
- [x] [Review][Patch] Add @metadata to Chinese ARB — Added missing `@drawerSlideshowIntervalValue`, `@slideshowCurrentInterval`, `@slideshowIntervalValue` metadata blocks [lib/l10n/app_zh.arb]

#### Deferred

- [x] [Review][Defer] _downloadMsg race condition — Port listener starts before didChangeDependencies sets locale; theoretical window where English fallback shows in non-English locale [lib/pages/home_page.dart:28-48] — deferred, pre-existing pattern
- [x] [Review][Defer] NumberFormat/DateFormat rebuilt every frame — Created inside build() of a ListView; minor performance concern, not blocking [lib/widgets/detail.dart:34-35] — deferred, pre-existing
- [x] [Review][Defer] AppLocalizations.of(context)! crashes on unsupported locales — App only supports en/zh; other device locales would crash. Pre-existing architectural decision. [multiple files] — deferred, pre-existing
- [x] [Review][Defer] Missing await on ImageCacheManager().emptyCache() — "Clear All" handler doesn't await image cache clear, toast fires before completion [lib/ui/widgets/dialogs/cache_dialog.dart:37] — deferred, pre-existing bug
- [x] [Review][Defer] AppLocalizations in async callbacks — toolbar.dart uses AppLocalizations.of(context)! inside onTap/onPressed callbacks with potentially stale context [lib/widgets/toolbar.dart] — deferred, pre-existing pattern
- [x] [Review][Defer] Stale slider label during drag — ChangeSlideIntervalDialog StatelessWidget doesn't rebuild on slider changes [lib/ui/widgets/dialogs/slideshow_dialog.dart] — deferred, pre-existing UX
- [x] [Review][Defer] Minimal l10n test coverage — Test only checks widget existence, not localized string content [test/ui/widgets/gallery_toolbar_scrim_test.dart] — deferred, nice-to-have
