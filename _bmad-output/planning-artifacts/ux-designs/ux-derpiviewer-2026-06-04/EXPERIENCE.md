---
schema: experience-md
version: "1.0"
name: derpiviewer
description: "Information architecture, interaction behaviors, and user flows for Derpiviewer — a Flutter-based Android image-board browser."
status: final
created: 2026-06-04
updated: 2026-06-04
design_ref: ./DESIGN.md
sources:
  - docs/project-overview.md
  - docs/component-inventory.md
  - docs/architecture.md
  - docs/api-contracts.md
  - docs/data-models.md
  - lib/style/theme.dart
  - lib/enums.dart
  - lib/main.dart
  - lib/pages/home_page.dart
  - lib/pages/search_page.dart
  - lib/pages/result_page.dart
  - lib/pages/fav_page.dart
  - lib/pages/gallery.dart
  - lib/widgets/image_grid.dart
  - lib/widgets/toolbar.dart
  - lib/widgets/detail.dart
  - lib/widgets/dialogs.dart
  - lib/widgets/icons.dart
  - lib/widgets/video_view.dart
  - lib/l10n/app_localizations_en.dart

screens:
  - HomePage
  - SearchPage
  - ResultPage
  - FavouritePage
  - GalleryView
  - ChangeBooruDialog
  - ChangeParamDialog
  - ChangeDownloadPrefDialog
  - ChangeKeyDialog
  - ClearCacheDialog
  - CustomAboutDialog
  - ChangeSlideIntervalDialog
  - ShareSheet
  - DetailSheet
---

# Derpiviewer — EXPERIENCE.md

> **Source:** Reverse-engineered from existing Flutter codebase. This document describes the as-built information architecture, flows, and interaction behaviors; no modifications are proposed unless explicitly tagged `[PRESCRIBED]`.

## Foundation

| Attribute | Value |
|-----------|-------|
| Platform | Android (Flutter) |
| Form factor | Mobile phone, portrait |
| UI system | Material Design (Flutter SDK) |
| Visual identity | `{DESIGN.md}` — color tokens, typography scale, spacing scale |
| State management | Provider + ChangeNotifier (MVVM-like) |
| i18n | English + Simplified Chinese via `flutter_localizations` |

## Information Architecture

```
📱 Derpiviewer
│
├── 🏠 HomePage [/]
│   ├── AppBar: "Derpiviewer ({booru})"
│   ├── Featured Image (tap → search by image ID)
│   ├── Trending Grid (infinite scroll)
│   ├── FABs: [⭐ Favorites] [🔍 Search]
│   └── ☰ Drawer
│       ├── DrawerHeader (image)
│       ├── Select Booru → ChangeBooruDialog
│       ├── Search Settings → ChangeParamDialog
│       ├── Size Settings → ChangeDownloadPrefDialog
│       ├── Clear Cache → ClearCacheDialog
│       ├── About → CustomAboutDialog
│       ├── Single Column Mode [Switch]
│       ├── Slideshow Interval → ChangeSlideIntervalDialog
│       └── Dark Mode [Switch]
│
├── 🔍 SearchPage [push from FAB or featured image]
│   └── AppBar
│       ├── Back button
│       ├── InputHistoryTextField (with persistence)
│       ├── Clear button
│       └── Search button
│
├── 📋 ResultPage [push from SearchPage]
│   ├── AppBar: "Searching: {query}"
│   └── Result Grid (infinite scroll)
│       └── Tap thumbnail → GalleryView
│
├── ⭐ FavouritePage [push from Favorites FAB]
│   ├── AppBar: "Favourites: {booru}"
│   └── Favorites Grid (infinite scroll, SQLite)
│       └── Tap thumbnail → GalleryView
│
└── 🖼️ GalleryView [push from any thumbnail]
    ├── Fullscreen viewer (PhotoViewGallery)
    ├── Slideshow toggle (top-right)
    ├── GalleryToolBar (bottom overlay)
    │   ├── ❤️ Favorite toggle
    │   ├── 📥 Download
    │   ├── 📤 Share → ShareSheet (BottomSheet)
    │   └── ℹ️ Info → DetailSheet (BottomSheet)
    └── Infinite-scroll load more at last image
```

### Surface-to-Need Mapping

| Need | Surface | How arrived |
|------|---------|-------------|
| Browse trending images | HomePage | App launch |
| Discover featured image | HomePage | Top of trending scroll |
| Search by keyword | SearchPage → ResultPage | FAB tap → enter query |
| Search by image ID | SearchPage → ResultPage | Tap featured image |
| View image fullscreen | GalleryView | Tap any thumbnail |
| Zoom into image | GalleryView | Pinch gesture |
| Navigate between images | GalleryView | Swipe left/right |
| Watch video | GalleryView | Auto-plays webm/mp4 |
| Auto-advance images | GalleryView | Slideshow toggle |
| Save to favorites | GalleryView toolbar | Heart icon tap |
| Download image/video | GalleryView toolbar | Download icon tap |
| Share image file | GalleryView toolbar → ShareSheet | Share → Share Picture |
| Share image link | GalleryView toolbar → ShareSheet | Share → Share Link |
| View image metadata | GalleryView toolbar → DetailSheet | Info icon tap |
| Copy tag / ID | DetailSheet | Tap chip |
| Open description links | DetailSheet | Tap markdown link (confirmed) |
| View favorites | FavouritePage | Favorites FAB tap |
| Switch booru host | HomePage drawer → ChangeBooruDialog | Drawer → Select Booru |
| Change sort/filter | HomePage drawer → ChangeParamDialog | Drawer → Search Settings |
| Change image sizes | HomePage drawer → ChangeDownloadPrefDialog | Drawer → Size Settings |
| Toggle dark mode | HomePage drawer | Bottom switch |
| Toggle single column | HomePage drawer | ListTile switch |
| Set slideshow speed | HomePage drawer → ChangeSlideIntervalDialog | Drawer → Slideshow Interval |
| Clear cache | HomePage drawer → ClearCacheDialog | Drawer → Clear Cache |
| View app info | HomePage drawer → CustomAboutDialog | Drawer → About |
| Go back | Any pushed page | AppBar back / system back |

## Voice and Tone

**Microcopy style:** Neutral and functional. English strings use short, direct labels:
- Action confirmations: "Downloading", "Faved", "ID Copied!"
- Navigation: "Select booru", "Search settings", "Size settings"
- Questions: "Are you sure you want to open the link?"

No personality or brand voice is injected into microcopy. Toast messages are single-word or short-phrase confirmations.

> ⚠️ **Known i18n gap:** The following drawer items are hardcoded in Chinese in `home_page.dart`, bypassing `AppLocalizations`: 清除缓存 (Clear Cache), 关于 (About), 单列模式 (Single Column Mode), 夜间模式 (Dark Mode), 幻灯片间隔 (Slideshow Interval). These display in Chinese even when the app language is set to English. Extraction to `.arb` files is needed for proper bilingual parity.

## Component Patterns

### AppBar
| Use | Behavioral rules |
|-----|------------------|
| Page header with title, optional back button, and actions | — Title text reflects current context (booru name, search query)<br>— Back button appears on all pushed pages<br>— `elevation: 0` maintains the flat visual aesthetic<br>— Color: `{DESIGN.md.colors.light.primary}` (light) / `{DESIGN.md.colors.dark.primary}` (dark) |

### FloatingActionButton (FAB)
| Use | Behavioral rules |
|-----|------------------|
| Primary navigation actions (Favorites, Search) | — Two FABs stacked vertically in bottom-right<br>— Top: navigates to FavouritePage; Bottom: navigates to SearchPage<br>— No debounce or navigation guard (tap twice → two pushed pages)<br>— Each FAB has a unique `heroTag` for independent animations |

### Drawer
| Use | Behavioral rules |
|-----|------------------|
| Settings hub and navigation center | — Header: full-width image with cover fit<br>— Items open dialogs (SimpleDialog / AlertDialog / AboutDialog)<br>— Switches apply instantly (no save/confirm step)<br>— Dark mode toggle at bottom, always visible via `Expanded`<br>— Icons use `{DESIGN.md.colors.light.foreground}` / `{DESIGN.md.colors.dark.foreground}` |

### Switch
| Use | Behavioral rules |
|-----|------------------|
| Boolean preference toggles (dark mode, single column) | — Instant state change via `PrefModel`<br>— Reduced touch target (`shrinkWrap`)<br>— No confirmation or undo<br>— Dark mode: triggers full `ThemeMode` switch in `MaterialApp` |

### DropdownMenu
| Use | Behavioral rules |
|-----|------------------|
| Enumerated preference selection (sort direction/field, filter, sizes) | — `DropdownMenu` (Material 3) at 70% screen width<br>— Selection applies immediately — no save button<br>— Filter change closes dialog and applies<br>— Width adapts to screen via `MediaQuery` |

### ImageGrid + ThumbHero (Thumbnail Grid)
| Use | Behavioral rules |
|-----|------------------|
| Infinite-scroll grid of square thumbnails | — `SliverGrid` with 1 or 2 columns (user pref)<br>— Each thumbnail: Hero widget with image ID as tag<br>— Tap → pushes GalleryView at tapped index<br>— URL selection: `mediumThumbUrl` (1-col) vs `thumbUrl` (2-col)<br>— Loading: individual per-image via CachedNetworkImage<br>— Error: `Icons.error` fallback per thumbnail<br>— No empty-state widget (0 images = silent blank grid)<br>— No pull-to-refresh |

### GalleryView + GalleryToolbar (Fullscreen Viewer)
| Use | Behavioral rules |
|-----|------------------|
| Fullscreen image/video viewer with zoom, swipe, slideshow, and actions | — **Navigation:** PageView swipe between images<br>— **Zoom:** Pinch 1.0×–4.0× *(zoom state not reset on page change — known gap)*<br>— **Hero:** Animated transition from thumbnail (tag = image ID)<br>— **Loading:** CircularProgressIndicator (determinate for images, adaptive for videos)<br>— **Error:** Icons.error_outline; no retry mechanism<br>— **Auto-load:** fetchMore() when reaching last image |

### GalleryToolBar (Overlay Toolbar)
| Use | Behavioral rules |
|-----|------------------|
| Bottom overlay with favorite, download, share, info actions | — Fixed `Row` of 4 IconButtons<br>— Icons: `#FFFFFF`; no background — relies on image content for visibility<br>— **Favorite:** toggle via FavIconController; toast confirms immediately (before DB write completes)<br>— **Download:** triggers async file write; toast "Downloading" fires optimistically<br>— **Share → ShareSheet:** ModalBottomSheet with Share Picture / Share Link<br>— **Info → DetailSheet:** ModalBottomSheet with full metadata |

### DetailSheet (Image Metadata)
| Use | Behavioral rules |
|-----|------------------|
| Bottom sheet showing image metadata, description, stats, and tags | — **ID Chip:** tappable → copies ID to clipboard + toast<br>— **Uploader:** tappable (UI shows blue link color but tap is not implemented on uploader text; only ID chip is active)<br>— **Date:** `yyyy-MM-dd HH:mm` — not locale-aware (known gap)<br>— **Description:** MarkdownBody, selectable; links trigger confirm AlertDialog before opening<br>— **Stats:** 4-column Row (upvotes/downvotes/faves/comments) — not numeric-formatted with locale separators (known gap)<br>— **Tags:** Wrap of color-coded Chips; tappable → copies tag to clipboard + toast<br>— Tags use `{DESIGN.md.colors.tag.[category].background}` / `{DESIGN.md.colors.tag.[category].foreground}` |

### VideoView (Video Player)
| Use | Behavioral rules |
|-----|------------------|
| Chewie-wrapped video player in GalleryView | — Auto-play + looping<br>— Loading: `CircularProgressIndicator.adaptive()`<br>— Error: `Icons.error_outline` (50px) — no retry mechanism<br>— No pause during slideshow auto-advance (video may be interrupted) |

### Favorite Icon (FavIcon)
| Use | Behavioral rules |
|-----|------------------|
| Toggleable heart icon in GalleryToolBar | — Active: `Icons.favorite` (filled), Inactive: `Icons.favorite_border` (outline)<br>— Driven by `ValueNotifier<bool>`<br>— Toast fires before async DB write: may show false confirmation<br>— Rapid toggle creates race condition (multiple concurrent DB writes) |

### Toast Feedback
| Use | Behavioral rules |
|-----|------------------|
| Single-line action confirmations | — Library: `fluttertoast`<br>— System-default style (not theme-matched)<br>— Fires optimistically before async completion<br>— No queuing — rapid actions may overlap or drop toasts |

### Dialog (Settings)
| Use | Behavioral rules |
|-----|------------------|
| Modal settings panels from Drawer | — `SimpleDialog`: list-of-options (booru hosts, dropdown configs)<br>— `AlertDialog`: single-value with Slider (slideshow interval) or confirmation prompts<br>— `AboutDialog`: read-only app info<br>— All dismissible by tap-outside or back<br>— Settings apply immediately — no explicit save/cancel pattern |

### Infinite Scroll
| Use | Behavioral rules |
|-----|------------------|
| Auto-load more content at list bottom | — `ScrollController` listener: `position.pixels == position.maxScrollExtent`<br>— Triggers `model.fetchMore()`<br>— No `hasMore` sentinel — continues calling API after exhaustion (known gap)<br>— No loading indicator at tail<br>— Content < viewport triggers continuous fetch loop (known gap) |

### Navigation
| Use | Behavioral rules |
|-----|------------------|
| Stack-based page routing | — All transitions: `Navigator.push(MaterialPageRoute(...))`<br>— No named routes, no deep linking<br>— Hero transition: thumbnails animate into GalleryView via `Hero(tag: imageId)`<br>— Back: AppBar leading button or system gesture |

## State Patterns

### Per-Component States

| Component | Cold load | Empty | Loading | Loaded | Error | Offline | Focus |
|-----------|-----------|-------|---------|--------|-------|---------|-------|
| ImageGrid | Blank (no skeleton) | Blank grid (no empty-state message) | Per-image progress indicators | Thumbnail grid | `Icons.error` per thumbnail | [NOT HANDLED] | [NOT HANDLED] |
| Featured Image | Container area (no skeleton) | N/A (always a fallback image) | `CircularProgressIndicator` via CachedNetworkImage | Cover-fit image | Fallback image URL | [NOT HANDLED] | N/A |
| Gallery (Image) | N/A (entered with data) | N/A (single item) | `CircularProgressIndicator` (determinate) | Fullscreen image | `Icons.error_outline` | [NOT HANDLED] | [NOT HANDLED] |
| Gallery (Video) | N/A | N/A | `CircularProgressIndicator.adaptive()` | Chewie player | `Icons.error_outline` (50px, no retry) | [NOT HANDLED] | [NOT HANDLED] |
| SearchPage | Blank body (Container) | N/A | N/A | N/A | N/A | N/A | `InputHistoryTextField` auto-focuses |
| ResultPage | Blank grid (no skeleton) | Blank grid (no "no results" message) | Same as ImageGrid | Search result grid | Same as ImageGrid | [NOT HANDLED] | [NOT HANDLED] |
| FavouritePage | Blank grid (no skeleton) | Blank grid (no "no favorites yet" message) | Same as ImageGrid | Favorites grid | Same as ImageGrid | [NOT HANDLED] | [NOT HANDLED] |
| DetailSheet | N/A | N/A | N/A | Full metadata ListView | N/A | [NOT HANDLED] | N/A |

### [PRESCRIBED] Empty State Guidance

| Surface | Recommended empty state |
|---------|-------------------------|
| HomePage (trending) | Skeleton grid: N placeholder cards matching current column layout, shimmer animation. When data arrives: fade in. |
| ResultPage (no results) | Centered illustration + "No results for '{query}'" + suggestion: "Try different search terms or check your filter settings." |
| FavouritePage (no favorites) | Centered heart-outline illustration + "No favorites yet" + hint: "Tap the heart icon on any image in the gallery to save it here." |
| Gallery (0 items) | Prevent navigation to gallery when list is empty; disable thumbnail taps on empty grids. |

### [PRESCRIBED] Offline State Handling

| Component | Offline behavior |
|-----------|-----------------|
| ImageGrid | Show cached images if available; non-intrusive banner at top: "You're offline — showing cached content." New fetches silently fail without disrupting existing grid. |
| Gallery | Show cached full-res image if available. Download and share actions show toast: "Unavailable offline." Favorite toggle continues working (local DB). |
| Search | Show banner: "Search requires an internet connection." Input field remains usable; search button disabled. |
| Favorites | Fully functional offline (SQLite local). No banner needed. |

## Interaction Primitives

| Gesture | Context | Behavior |
|---------|---------|----------|
| **Tap** | Thumbnail | Navigate to GalleryView with Hero transition |
| **Tap** | Gallery toolbar icon | Trigger action (fav/download/share/info) |
| **Tap** | Drawer ListTile | Open dialog or toggle switch |
| **Tap** | ID chip in DetailSheet | Copy ID to clipboard + toast |
| **Tap** | Tag chip in DetailSheet | Copy tag to clipboard + toast |
| **Tap** | Markdown link in description | Confirm dialog → launch URL in browser |
| **Tap** | Featured image | Navigate to SearchPage with `id:...` pre-filled |
| **Swipe (L/R)** | Gallery | Previous/next image (PageView) |
| **Pinch** | Gallery | Zoom in/out (1.0×–4.0×) |
| **Scroll (vertical)** | Trending/Search/Favorites grids | Scroll grid; trigger `fetchMore()` at bottom |
| **Toggle** | Drawer switches | Instant state change (dark mode, single column) |
| **Slider drag** | Slideshow interval dialog | Real-time value preview; closes on OK button |
| **Dropdown select** | Settings dialogs | Immediate apply (no save button needed) |

**Not implemented:**
- Long-press (no context menus)
- Pull-to-refresh
- Double-tap to zoom
- Drag-and-drop

## Accessibility Floor

| Criterion | Status | Details |
|-----------|--------|---------|
| Tooltips on icon buttons | ⚠️ Partial | SearchPage has `tooltip: 'Back'`, `tooltip: 'Clear'`; most other IconButtons lack tooltips |
| Semantic labels | ❌ Missing | No `Semantics` widgets or `semanticLabel` properties found |
| Screen reader support | ❌ Missing | No explicit accessibility configuration |
| Contrast — body text (light) | ✅ WCAG AA | `#0000008A` on `#FFFFFF` ≈ 4.6:1 |
| Contrast — body text (dark) | ✅ WCAG AAA | `#FFFFFF` on `#303030` ≈ 15.4:1 |
| Contrast — tag chips (light) | ⚠️ Partial | 6 of 12 categories below 4.5:1 on white chip background; body tags at 5.9:1 pass |
| Contrast — tag chips (dark) | 🔴 Critical | 11 of 12 foreground colors fall below 4.5:1 on `#303030`; body tags at 1.9:1 are invisible |
| Contrast — toolbar icons | 🔴 Critical | `#FFFFFF` icons have no background; invisible on light/white image areas |
| Touch target size | ✅ Adequate | IconButtons are Material default 48×48; chips are ~32px; Switch uses shrinkWrap (reduced) |
| Focus management | ⚠️ Implicit | Relies on default Material focus traversal; no explicit focus order |
| Motion sensitivity | ⚠️ Not respected | Slideshow timer does not check `MediaQuery.of(context).disableAnimations` |
| Text scaling | ✅ Default | Relies on Flutter's built-in text scaling |
| Keyboard navigation | ❌ N/A | Android touch-first; no keyboard shortcuts |

> **Design note:** Color contrast values in DESIGN.md now include per-category contrast ratios against both light (`#FFFFFF`) and dark (`#303030`) chip backgrounds in `{DESIGN.md.colors.tag}`.

## Key Flows

### Flow 1: Casual Browsing
> **Protagonist:** Skeeter — killing time, no specific goal, open to discovery.

1. **Launch** → HomePage loads; featured image appears at top, trending grid populates below
2. **Scroll** trending grid; app fetches more pages silently as he reaches the bottom
3. **Tap** a thumbnail that catches his eye → Hero transition to GalleryView at that index
4. **Swipe** left/right to browse neighboring images; pinch to zoom on details
5. **Tap** heart icon → icon fills, toast "Faved" confirms
6. **Swipe** back / **tap** back button → return to HomePage at previous scroll position
7. ⚡ *Climax: The heart icon fills — instant visual confirmation the image is saved.*

**Failure:** Network drops during trending load → grid stops at last loaded page; no error message. [PRESCRIBED] Show unobtrusive "Couldn't load more — tap to retry" at grid bottom. / Gallery image fails to load → error icon displayed; no retry. [PRESCRIBED] Add "Tap to retry" on error state.

### Flow 2: Targeted Search
> **Protagonist:** Mary — knows what she wants, searches for specific character art.

1. From HomePage drawer, **configure** Search Settings (sort field, direction, filter) → changes apply immediately
2. Close drawer, **tap** Search FAB → SearchPage with `InputHistoryTextField` auto-focused
3. **Type** query (e.g., "twilight sparkle, safe") — search history surfaces past queries as suggestions
4. **Tap** Search icon (or keyboard submit) → ResultPage with "Searching: {query}" AppBar
5. **Scroll** results grid; auto-fetch more pages as she reaches bottom
6. **Tap** a result thumbnail → GalleryView at that index
7. ⚡ *Climax: The first batch of search results loads — Mary sees instantly whether the search worked.*

**Failure:** API returns 0 results → blank grid with no message. [PRESCRIBED] Show "No results for '{query}'" with suggestions. / API returns error → same blank grid. [PRESCRIBED] Show error message with retry button. / Empty search query submitted → should be prevented. [PRESCRIBED] Disable search button when input is empty.

### Flow 3: Favorites Management
> **Protagonist:** Pary — curates a personal collection, occasionally removes items.

1. **Tap** Favorites FAB → FavouritePage with "Favourites: {booru}" AppBar
2. **Scroll** favorites grid; more items load from SQLite as she reaches bottom
3. **Tap** a thumbnail → GalleryView
4. **Swipe** through favorites in fullscreen
5. **Tap** filled heart on an image she no longer wants → heart becomes outline, toast "Unfaved"
6. **Tap** back → FavouritePage (note: stale snapshot — the unfaved image may still appear until next refresh)
7. ⚡ *Climax: The heart toggles from filled to outline — immediate visual confirmation of removal.*

**Failure:** DB write fails after unfav → toast already showed "Unfaved" (false positive). [PRESCRIBED] Move toast to after successful DB write; show "Failed to update favorite" on error. / Image removed from favorites but FavouritePage shows stale data → [PRESCRIBED] Reload favorites data when FavouritePage regains visibility.

### Flow 4: Settings Configuration
> **Protagonist:** Skeeter — wants to switch booru, enable dark mode, set single column.

1. **Open** drawer (hamburger icon or edge swipe)
2. **Tap** "Select booru" → ChangeBooruDialog lists all 7 booru hosts by domain name
3. **Tap** a host → dialog closes; toast "Switching to {host}, please wait"; trending reloads
4. **Toggle** Dark Mode switch at drawer bottom → instant theme transition (no animation — known gap)
5. **Toggle** Single Column switch → grid immediately re-renders in 1-column layout
6. **Close** drawer → HomePage now in dark mode, single column, showing content from the new booru
7. ⚡ *Climax: The instant theme flip — Skeeter immediately knows dark mode took effect.*

**Failure:** Booru switch while trending data is loading → old booru's images may appear in new booru's grid (cross-booru data pollution). [PRESCRIBED] Cancel all in-flight requests on booru switch; clear grid; show loading state for new data. / API key entered is invalid → no validation; searches may silently fail with permission errors. [PRESCRIBED] Show error toast on 403 responses; offer to re-enter API key.

### Flow 5: Image Detail Inspection
> **Protagonist:** Mary — found an interesting image, wants to check tags, stats, and source.

1. In GalleryView, **tap** Info icon → DetailSheet slides up from bottom
2. **Read** uploader name (blue link color), upload date, and markdown description
3. **Scan** stats Row: upvotes (green ↑), downvotes (red ↓), faves (yellow ★), comments (purple 💬)
4. **Tap** a tag chip → tag text copied to clipboard; toast "Tag Copied!"
5. **Tap** a link in the description → AlertDialog: "Are you sure you want to open the link?" → Confirm → opens in browser
6. **Swipe down** / **tap** outside → dismiss DetailSheet, return to GalleryView
7. ⚡ *Climax: The full tag list with color-coded categories — immediate understanding of how the image is classified.*

**Failure:** Description contains a broken/malicious link → [PRESCRIBED] Show error if URL fails to launch (currently uses `canLaunchUrl` guard but no error message on failure). / Tag text is extremely long → [PRESCRIBED] Set `overflow: TextOverflow.ellipsis` on chip labels; consider max chip width.

## Inspiration & Anti-patterns

### Inspired by
- **Material Design (Google)** — default component library, elevation system, and motion patterns. Derpiviewer adopts Material with minimal customization: flat AppBar, default FAB elevation, standard dialog patterns.
- **Derpibooru.org web interface** — the color-coded tag category system (12 categories with unique color pairs) is directly adapted from the Philomena web taxonomy.
- **PhotoView / Chewie** — pinch-to-zoom gallery and video playback patterns are inherited from these third-party Flutter packages with default configurations.

### Rejected / Not adopted
- **Pull-to-refresh** — the app relies entirely on infinite scroll; no refresh gesture exists on any surface. Rationale: content is append-only streams; stale data is not the primary concern.
- **Bottom navigation bar** — the standard Material 3 NavigationBar pattern is rejected in favor of a dual-FAB layout + drawer. Rationale: two primary actions (search, favorites) fit in FABs; secondary actions live in drawer.
- **Named routes / deep linking** — no URL-based navigation or Firebase Dynamic Links. Rationale: single-purpose app with linear navigation; deep linking adds complexity with no user benefit identified.
- **Animated theme transitions** — theme switch is instant (no cross-fade). Rationale: legacy codebase; not an intentional UX decision. [PRESCRIBED] Consider adding 300ms cross-fade for theme transition.
- **Brand identity** — no logo, custom icon, or color palette. All visual branding decisions deferred. Rationale: solo developer project; content-first philosophy.

## Glossary

| Term | Definition |
|------|------------|
| **booru** | An image-board website powered by the Philomena software (Derpibooru, Trixiebooru, etc.). Derpiviewer supports 7 booru hosts. |
| **Philomena** | Open-source image-board platform. Its JSON API is the data source for all content in Derpiviewer. |
| **Hero transition** | A Flutter animation where a widget "flies" from one screen to another during navigation. Used for thumbnail-to-gallery transitions. |
| **SliverGrid** | Flutter's scrollable 2D grid widget. Used for image thumbnails in trending, search, and favorites. |
| **ChangeNotifier** | Flutter's built-in observable state class. Models extend ChangeNotifier; widgets listen via Consumer/Provider. |
| **Provider** | Flutter state management library. Wraps InheritedWidget for dependency injection and reactive UI updates. |
| **CachedNetworkImage** | Flutter widget that loads and caches network images. Provides loading, error, and placeholder states. |
| **Chewie** | Flutter video player wrapper with Material-styled controls. Wraps video_player with play/pause/seek UI. |
| **SearchInterface** | Abstract Dart class defining the contract for any image-list data source (trending, search, favorites). Enables GalleryView and ImageGrid to work with any model. |
| **TagCategory** | Enum classifying image tags into 12 categories (general, artist, rating, character, oc, species, body, official, fanmade, origin, spoiler, error). Each has a color pair. |
| **FAB** | Floating Action Button — Material Design's primary action button, elevated above content with a circular shape. |

## Responsive & Platform

**Single platform:** Android mobile phones. No tablet, desktop, or web layouts exist.

The only layout adaptation is the **single/dual column toggle** — a user preference, not a breakpoint-driven responsive behavior. In single-column mode, the grid uses `mediumThumbUrl` (larger thumbnails); in dual-column, `thumbUrl` (smaller).

No `MediaQuery` or `LayoutBuilder` breakpoint logic is present. The app assumes portrait orientation. No landscape adaptations exist.

### [PRESCRIBED] RTL Readiness

If RTL language support is added in the future, verify:
- Gallery toolbar `Row` icon order reverses correctly (Flutter handles this via `Directionality`)
- Drawer `ListTile` leading icon/title order reverses correctly
- FAB column positioning: should move to bottom-left in RTL
- Any `EdgeInsets.only(left:/right:)` values swap appropriately
