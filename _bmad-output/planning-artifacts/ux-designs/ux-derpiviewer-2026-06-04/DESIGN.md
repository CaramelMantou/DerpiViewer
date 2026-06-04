---
schema: design-md
version: "1.0"
name: derpiviewer
description: "Visual design specification for Derpiviewer — a Flutter-based Android image-board browser. Dual-theme Material Design with content-first aesthetic."
status: final
created: 2026-06-04
updated: 2026-06-04
source: Brownfield reverse-engineering from lib/ Flutter source

colors:
  light:
    primary: "#2196F3"
    foreground: "#0000008A"
    background: "#FFFFFF"
    title: "#FFFFFF"
    bar-foreground: "#FFFFFF"
    scaffold: "#FFFFFF"

  dark:
    primary: "#607D8B"
    foreground: "#FFFFFF"
    background: "#303030"
    title: "#FFFFFF"
    bar-foreground: "#FFFFFF"
    scaffold: "#303030"

  tag:
    general:
      background: "#D0E29C"
      foreground: "#6F8F0E"
    artist:
      background: "#B9BCE1"
      foreground: "#393F85"
    rating:
      background: "#C1D7E4"
      foreground: "#267EAD"
    character:
      background: "#B5DFD8"
      foreground: "#2D8677"
    oc:
      background: "#DEC5E2"
      foreground: "#9852A3"
    species:
      background: "#E6C9B5"
      foreground: "#8B552F"
    body:
      background: "#C1C1C1"
      foreground: "#4E4E4E"
    official:
      background: "#EDE697"
      foreground: "#998E1A"
    fanmade:
      background: "#EFD7E7"
      foreground: "#BB5496"
    origin:
      background: "#B9BCE1"
      foreground: "#393F85"
    spoiler:
      background: "#F4CDC2"
      foreground: "#C24523"
    error:
      background: "#EEB1BC"
      foreground: "#AD263F"

  semantic:
    upvote: "#4CAF50"
    downvote: "#F44336"
    faves: "#F9A825"
    comments: "#CE93D8"
    uploader-link: "#2887CB"
    hyperlink: "#2196F3"

typography:
  fontFamily: "System default (Roboto on Android)"
  scale:
    - role: caption
      size: 12
      lineHeight: 1.33
      weight: 400
      usage: "Drawer subtitles, API hint text"
    - role: body
      size: 14
      lineHeight: 1.43
      weight: 400
      usage: "Primary content text (Material default)"
    - role: body-large
      size: 16
      lineHeight: 1.5
      weight: 400
      usage: "Dialog option text, detail labels, chip labels"
    - role: heading
      size: 18
      lineHeight: 1.33
      weight: 700
      usage: "Detail sheet headings (uploader, Tags label)"
    - role: title
      size: 20
      lineHeight: 1.2
      weight: 400
      usage: "AppBar title"
  note: "Type scale is invariant across light/dark themes"

rounded:
  global: 4
  chips: 8
  dialogs: 4
  bottom-sheets: 4
  thumbnails: 0
  note: "Values in logical pixels; chip radius is Material default stadium shape (max-radius)"

spacing:
  scale:
    "1": 4
    "2": 8
    "3": 12
    "4": 16
    "5": 24
  layout:
    grid-item-spacing: 7
    grid-child-aspect-ratio: 1.0
    fab-stack-gap: 10
    drawer-bottom-padding-h: 16
    drawer-bottom-padding-v: 12
    detail-sheet-padding-h: 16
    detail-sheet-padding-v: 8
    tag-wrap-h-gap: 8
    tag-wrap-v-gap: 4
    section-gap: 16
    toolbar-bottom-padding: 8
    toolbar-left-padding: 10
    featured-image-spacer: 8
    dialog-dropdown-padding-h: 16
    dialog-dropdown-padding-v: 8
    dialog-textfield-padding: 16

components:
  app-bar:
    elevation: 0
    background: "{colors.light.primary}"
    title-color: "{colors.light.title}"
    title-size: "{typography.scale[title].size}"
    icon-color: "{colors.light.bar-foreground}"
    dark-mode:
      background: "{colors.dark.primary}"
      title-color: "{colors.dark.title}"
      icon-color: "{colors.dark.bar-foreground}"

  floating-action-button:
    background: "{colors.light.primary}"
    foreground: "{colors.light.bar-foreground}"
    layout: "stacked (Column, 2 FABs)"
    gap: "{spacing.layout.fab-stack-gap}"
    hero-tags: ["fav-fab", "sch-fab"]
    dark-mode:
      background: "{colors.dark.primary}"
      foreground: "{colors.dark.bar-foreground}"

  drawer:
    header: "CachedNetworkImage, BoxFit.cover, SizedBox.expand"
    header-image: "https://derpicdn.net/img/2015/9/26/988523/medium.png"
    item: "ListTile: leading Icon + title + optional subtitle (caption size) + optional trailing Switch"
    bottom-bar: "Expanded → Align(bottomCenter) → Container with dark-mode Row"
    background: "{colors.light.background}"
    text-color: "{colors.light.foreground}"
    dark-mode:
      background: "{colors.dark.background}"
      text-color: "{colors.dark.foreground}"

  thumbnail:
    container: "SizedBox.expand → Hero(tag: imageId) → Material(transparent) → InkWell(onTap) → CachedNetworkImage(BoxFit.cover)"
    rounding: "{rounded.thumbnails}"
    hero-tag: "image ID (int)"
    error-fallback: "Icons.error"

  image-grid:
    type: "SliverGrid"
    delegate: "SliverGridDelegateWithFixedCrossAxisCount"
    cross-axis-count: "1 (single-column) or 2 (dual-column) via user preference"
    child-aspect-ratio: "{spacing.layout.grid-child-aspect-ratio}"
    spacing: "{spacing.layout.grid-item-spacing}"

  gallery-viewer:
    type: "PhotoViewGallery.builder"
    min-scale: 1.0
    max-scale: 4.0
    page-transition: "default PageView swipe"
    overlay:
      toolbar: "{components.gallery-toolbar}"
      slideshow-toggle:
        position: "top-right (32px top, 16px right)"
        icon-color: "{colors.light.foreground}"
        icon-size: 28

  gallery-toolbar:
    layout: "Row(mainAxisAlignment: spaceEvenly), 4 Expanded children"
    buttons:
      - icon: "Icons.favorite / Icons.favorite_border"
        label: "Favorite toggle"
      - icon: "Icons.download"
        label: "Download"
      - icon: "Icons.share"
        label: "Share"
      - icon: "Icons.info"
        label: "Info"
    icon-color: "#FFFFFF"
    background: "none (transparent overlay)"
    note: "Icons have no background; visibility depends on image content underneath"

  detail-sheet:
    id-chip: "Chip with bold text, tappable → copy to clipboard"
    uploader: "18px bold, {colors.semantic.uploader-link}"
    date-format: "yyyy-MM-dd HH:mm"
    description: "MarkdownBody, selectable, links tappable with AlertDialog confirmation"
    stats: "Row of 4 Expanded columns: upvotes({colors.semantic.upvote}) ↓ downvotes({colors.semantic.downvote}) ★ faves({colors.semantic.faves}) 💬 comments({colors.semantic.comments})"
    tags: "Wrap of color-coded Chips — background: {colors.tag.[category].background}, foreground: {colors.tag.[category].foreground}; tappable → copy to clipboard"

  video-player:
    wrapper: "ChewieController (autoPlay: true, looping: true)"
    loading: "CircularProgressIndicator.adaptive()"
    error: "Icons.error_outline (size 50, no retry mechanism)"

  fav-icon:
    active: "Icons.favorite (filled)"
    inactive: "Icons.favorite_border (outline)"
    color: "#FFFFFF"
    animation: "ValueNotifier<bool> toggle (no animated transition)"

  dialogs:
    types:
      - "SimpleDialog: booru selector, search params (3 DropdownMenus), size prefs (4 DropdownMenus), API key (TextField), clear cache (3 ListTiles)"
      - "AlertDialog: slideshow interval (Slider 1-30s), URL open confirm"
      - "AboutDialog: app info, clickable GitHub link"

  toast:
    library: "fluttertoast"
    style: "system default (no app-theme matching)"
    usage: "Action confirmations (downloaded, faved, id copied, tag copied, cache cleared)"

  switch:
    tap-target-size: "shrinkWrap (reduced)"
    states:
      - "on — {colors.light.primary} / {colors.dark.primary}"
      - "off — Material default track"

  dropdown:
    type: "DropdownMenu (Material 3)"
    width: "70% screen width"
    usage: "Sort direction, sort field, filter, size preferences"
---

# Derpiviewer — DESIGN.md

> **Source:** Reverse-engineered from existing Flutter codebase. This document describes the as-built visual design; no modifications are proposed.

## Brand & Style

Derpiviewer is a utilitarian image-board browser with no formal brand identity. It uses Material Design defaults throughout — no custom logo, icon, or branded color scheme. The visual language prioritizes content (images) over chrome.

**Tone:** Functional, unobtrusive, content-first. The UI recedes so the images take center stage.

## Colors

### Light Theme

| Token | Hex | Role |
|-------|-----|------|
| `{colors.light.primary}` | `#2196F3` | AppBar, FAB, active states |
| `{colors.light.foreground}` | `#0000008A` | Body text, ListTile text/icons |
| `{colors.light.background}` | `#FFFFFF` | Scaffold, Drawer, Dialogs, Chips |
| `{colors.light.title}` | `#FFFFFF` | AppBar title, headline text |
| `{colors.light.bar-foreground}` | `#FFFFFF` | AppBar icons, FAB icons |

### Dark Theme

| Token | Hex | Role |
|-------|-----|------|
| `{colors.dark.primary}` | `#607D8B` | AppBar, FAB, active states |
| `{colors.dark.foreground}` | `#FFFFFF` | Body text, ListTile text/icons |
| `{colors.dark.background}` | `#303030` | Scaffold, Drawer, Dialogs, Chips |
| `{colors.dark.title}` | `#FFFFFF` | AppBar title, headline text |
| `{colors.dark.bar-foreground}` | `#FFFFFF` | AppBar icons, FAB icons |

### Tag Category Colors

Each tag category has a distinct background/foreground pair, used in `Chip` widgets throughout the DetailSheet:

| Category | Background | Foreground | Contrast ratio (on `#FFFFFF`) | Contrast ratio (on `#303030`) |
|----------|-----------|------------|-------------------------------|-------------------------------|
| general | `{colors.tag.general.background}` | `{colors.tag.general.foreground}` | 3.3:1 ⚠️ | 3.3:1 ⚠️ |
| artist | `{colors.tag.artist.background}` | `{colors.tag.artist.foreground}` | 4.7:1 ✅ | 4.1:1 ⚠️ |
| rating | `{colors.tag.rating.background}` | `{colors.tag.rating.foreground}` | 4.9:1 ✅ | 4.7:1 ✅ |
| character | `{colors.tag.character.background}` | `{colors.tag.character.foreground}` | 4.5:1 ✅ | 4.4:1 ⚠️ |
| oc | `{colors.tag.oc.background}` | `{colors.tag.oc.foreground}` | 4.8:1 ✅ | 4.1:1 ⚠️ |
| species | `{colors.tag.species.background}` | `{colors.tag.species.foreground}` | 4.1:1 ⚠️ | 3.7:1 ⚠️ |
| body | `{colors.tag.body.background}` | `{colors.tag.body.foreground}` | 5.9:1 ✅ | **1.9:1** 🔴 |
| official | `{colors.tag.official.background}` | `{colors.tag.official.foreground}` | 3.5:1 ⚠️ | 3.5:1 ⚠️ |
| fanmade | `{colors.tag.fanmade.background}` | `{colors.tag.fanmade.foreground}` | 4.2:1 ⚠️ | 3.6:1 ⚠️ |
| origin | `{colors.tag.origin.background}` | `{colors.tag.origin.foreground}` | 4.7:1 ✅ | 4.1:1 ⚠️ |
| spoiler | `{colors.tag.spoiler.background}` | `{colors.tag.spoiler.foreground}` | 4.0:1 ⚠️ | 4.2:1 ⚠️ |
| error | `{colors.tag.error.background}` | `{colors.tag.error.foreground}` | 4.8:1 ✅ | 3.9:1 ⚠️ |

> ⚠️ **Known issue:** Tag colors were designed for light backgrounds. On dark mode (`#303030`), several foreground colors fall below WCAG AA 4.5:1. The `body` category is essentially invisible at 1.9:1. A dark-mode-specific set of tag foreground colors is needed for production use.

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `{colors.semantic.upvote}` | `#4CAF50` | Upvote count + icon |
| `{colors.semantic.downvote}` | `#F44336` | Downvote count + icon |
| `{colors.semantic.faves}` | `#F9A825` | Fave count + star icon |
| `{colors.semantic.comments}` | `#CE93D8` | Comment count + icon |
| `{colors.semantic.uploader-link}` | `#2887CB` | Uploader name in detail sheet |
| `{colors.semantic.hyperlink}` | `#2196F3` | Tappable links in description |

## Typography

**Font family:** System default (Roboto on Android). No custom fonts loaded. Type scale is invariant across light/dark themes.

| Role | Size | Line height | Weight | Usage |
|------|------|-------------|--------|-------|
| caption | 12px | 1.33 | 400 | Drawer subtitles, API hint text |
| body | 14px | 1.43 | 400 | Primary content text |
| body-large | 16px | 1.5 | 400 | Dialog option text, detail labels, chip labels |
| heading | 18px | 1.33 | 700 | Detail sheet headings (uploader, Tags label) |
| title | 20px | 1.2 | 400 | AppBar title |

## Layout & Spacing

**Grid:**
- 1 or 2 cross-axis columns (user toggle)
- 1:1 child aspect ratio (square thumbnails)
- 7px main-axis and cross-axis spacing between thumbnails

**Spacing scale:** `4 / 8 / 12 / 16 / 24` px

**Insets:**
- Detail sheet: 16px horizontal, 8px vertical
- Tag wrap: 8px horizontal gap, 4px vertical run spacing
- Dialog dropdowns: 16px horizontal, 8px vertical
- FAB column: 10px between stacked buttons
- Featured image spacer: 8px height
- Drawer bottom bar: 16px horizontal, 12px vertical
- Section gaps: 16px
- Toolbar overlay: 8px bottom padding, 10px left padding

## Elevation & Depth

- **AppBar:** elevation 0 (flat, no shadow)
- **FAB:** Material default (6 resting)
- **Drawer:** Material default
- **BottomSheet/Modal:** Material default modal elevation
- **Dialogs:** Material default

Overall depth is minimal. The only elevated elements are the FABs over the content and modal overlays.

## Shapes

- **Thumbnails:** 0px radius (sharp rectangles), via `Material(color: Colors.transparent)` + `InkWell`
- **Chips:** 8px radius (stadium shape)
- **Dialogs:** 4px radius
- **Bottom sheets:** 4px radius (Material default)

## Components

### AppBar
- `elevation: 0` — flat, flush with content
- Background: `{colors.light.primary}` (light) / `{colors.dark.primary}` (dark)
- Title: 20px, `{colors.light.title}` / `{colors.dark.title}`
- Icons: `{colors.light.bar-foreground}` / `{colors.dark.bar-foreground}`
- Back button present on pushed pages (Search, Results, Favorites)

### FloatingActionButton
- Dual FABs stacked vertically in a `Column`, bottom-right
- Top: Favorites (`Icons.favorite`) — heroTag: `"fav-fab"`
- Bottom: Search (`Icons.search`) — heroTag: `"sch-fab"`
- 10px gap between FABs
- Background: `{colors.light.primary}` (light) / `{colors.dark.primary}` (dark)
- Foreground: `{colors.light.bar-foreground}` / `{colors.dark.bar-foreground}`

### Drawer
- **Header:** `CachedNetworkImage` with `BoxFit.cover`, full-width. Image URL: `https://derpicdn.net/img/2015/9/26/988523/medium.png`
- **Items:** `ListTile` rows — leading `Icon` + `title` (body-large) + optional `subtitle` (caption) + optional trailing `Switch`
- **Bottom bar:** Dark mode toggle pinned via `Expanded` + `Align(alignment: bottomCenter)`
- Background: `{colors.light.background}` / `{colors.dark.background}`
- Text: `{colors.light.foreground}` / `{colors.dark.foreground}`

### Image Grid (Thumbnail)
- `SliverGrid` with `SliverGridDelegateWithFixedCrossAxisCount`
- Column count: 1 (single) or 2 (dual) based on user toggle
- Child: `ThumbHero` — `SizedBox.expand → Hero(tag: id) → Material(transparent) → InkWell(onTap) → CachedNetworkImage(BoxFit.cover)`
- URL: `mediumThumbUrl` (single-column), `thumbUrl` (dual-column)
- Error: `Icons.error`

### Gallery Viewer
- `PhotoViewGallery.builder` with PageView navigation
- Scale: min 1.0×, max 4.0× (pinch-to-zoom)
- Hero animation: tag = image ID
- Image: `CachedNetworkImage` + `CircularProgressIndicator` (determinate)
- Video: `VideoView` (Chewie, autoPlay, looping)
- Error: `Icons.error_outline`
- Overlay: GalleryToolBar (bottom) + slideshow toggle (top-right)

### Gallery Toolbar
- `Row` with 4 `Expanded` children, `MainAxisAlignment.spaceEvenly`
- Icons: Favorite (heart toggle), Download, Share, Info
- Icon color: `#FFFFFF`
- No background — relies on image content for visibility (known issue: invisible on light images)
- Share → `ModalBottomSheet` (Share Picture / Share Link)
- Info → `ModalBottomSheet` (DetailSheet)

### Detail Sheet
- **ID:** `Chip`, bold, tappable → copies to clipboard
- **Uploader:** heading size + bold, `{colors.semantic.uploader-link}`
- **Date:** `yyyy-MM-dd HH:mm` (not locale-aware — known gap)
- **Description:** `MarkdownBody`, selectable, links tappable with confirmation `AlertDialog`
- **Stats:** 4-column Row — ↑ `{colors.semantic.upvote}` / ↓ `{colors.semantic.downvote}` / ★ `{colors.semantic.faves}` / 💬 `{colors.semantic.comments}`
- **Tags:** `Wrap` of `Chip` — color-coded per category using `{colors.tag.[category]}` pairs; tappable → copies tag to clipboard

### Video Player
- `ChewieController` wrapping `VideoPlayerController`
- Auto-play + looping
- Loading: `CircularProgressIndicator.adaptive()`
- Error: `Icons.error_outline` (size 50) — no retry mechanism (known gap)

### Favorite Icon
- Active: `Icons.favorite` (filled), Inactive: `Icons.favorite_border` (outline)
- Color: `#FFFFFF`
- State via `ValueNotifier<bool>`, no animated transition

### Dialogs
- **SimpleDialog** — Booru selector, search params (3 `DropdownMenu`s at 70% screen width), size prefs (4 `DropdownMenu`s), API key (`TextField`), clear cache (3 `ListTile`s)
- **AlertDialog** — Slideshow interval (`Slider` 1-30s), URL open confirmation
- **AboutDialog** — App name, version, author, clickable GitHub link

### Toast
- Library: `fluttertoast`, system-default style (no app-theme matching)
- Used for action confirmations only: "Downloaded", "Faved", "Unfaved", "ID Copied!", "Tag Copied!", cache cleared messages
- Known gap: fires before async operation completes (may show false confirmations on failure)

### Switch
- `MaterialTapTargetSize.shrinkWrap` (reduced touch target)
- On-track: `{colors.light.primary}` / `{colors.dark.primary}`
- Used for: dark mode toggle (drawer bottom), single-column toggle (drawer)

### Dropdown
- `DropdownMenu` (Material 3)
- Width: 70% screen width
- Used in: ChangeParamDialog (sort direction/field/filter), ChangeDownloadPrefDialog (image/video preview, download, share sizes)

## Do's and Don'ts

### Do
- Reference theme tokens from `{colors.light.*}` or `{colors.dark.*}` for theme-adaptive values
- Use `{colors.tag.[category].background}` / `{colors.tag.[category].foreground}` for tag chip coloring
- Maintain the 4-8-12-16-24 spacing scale for all new components
- Keep the title → body → caption type hierarchy
- Use elevation 0 for AppBar to maintain the flat content-first aesthetic
- Wrap thumbnails in Hero with image ID as tag for gallery transition

### Don't
- Don't hardcode colors — reference DESIGN.md color tokens
- Don't add elevation to non-modal surfaces (the visual language is flat)
- Don't override the type scale without adding a new role to `{typography.scale}`
- Don't use custom fonts without updating `{typography.fontFamily}`
- Don't change tag category color assignments — these match the Philomena taxonomy
