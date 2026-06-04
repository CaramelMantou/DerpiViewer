---
baseline_commit: 94b4ac096bb075b32ba6ee2b0352db7c5010d438
---

# Story 3.2: Dark Mode Tag Contrast Fix and Theme Transition Animation

Status: review

## Story

As a user,
I want tag chips to be readable in dark mode and theme switching to animate smoothly,
so that the app feels polished in both light and dark themes.

## Acceptance Criteria

1. **Given** the app is in dark mode (scaffold background `#303030`)
   **When** the user opens a DetailSheet with tag chips
   **Then** all 12 tag category foreground colors meet WCAG AA contrast ratio (≥4.5:1) against their chip background
   **And** the `body` tag category is clearly visible (replacing the current `#4E4E4E` that has 1.9:1 contrast against `#303030`)
   **And** tag chips retain their category identity (background color distinguishes general from artist from rating, etc.)

2. **Given** `lib/config/tag_categories.dart` defines color entries
   **When** a developer reads the config
   **Then** each TagCategory entry provides: `tagBackColors` (unchanged), `tagForeColorsLight` (current values), `tagForeColorsDark` (new dark-mode values — minimum 4.5:1 contrast against the category background)
   **And** a `tagForeColor(TagCategory, Brightness)` helper function returns the correct foreground
   **And** `DetailSheet` uses `tagForeColor(tc, Theme.of(context).brightness)` instead of `tagForeColors[tc]`

3. **Given** the user toggles the dark mode switch in the drawer
   **When** `PrefModel.toggleDarkMode()` fires
   **Then** the theme transition uses a 300ms cross-fade animation via `AnimatedTheme`
   **And** the transition curve is `Curves.easeInOut`
   **And** the transition is smooth with no jarring flash

4. **Given** `flutter analyze` runs
   **Then** zero errors
   **And** all existing tests continue to pass with zero regressions

## Tasks / Subtasks

- [x] Task 1: Restructure `tag_categories.dart` with dual-theme foreground colors (AC: 1, 2)
  - [x] Rename `tagForeColors` → `tagForeColorsLight` (keep existing values)
  - [x] Add `tagForeColorsDark` map with 12 new dark-mode foreground colors
  - [x] Add `tagForeColor(TagCategory category, Brightness brightness)` helper function
  - [x] Each dark foreground must have ≥4.5:1 contrast against its `tagBackColors[category]`
  - [x] Verify: no other code changes needed to `tagBackColors` (backgrounds work for both themes)

- [x] Task 2: Update `detail.dart` to use theme-aware foreground (AC: 2)
  - [x] Change `tagForeColors[tc]` → `tagForeColor(tc, Theme.of(context).brightness)`
  - [x] Run `flutter analyze` — verify zero errors

- [x] Task 3: Add theme transition animation (AC: 3)
  - [x] In `lib/main.dart` `DVApp.build()`: wrap `MaterialApp` with `AnimatedTheme`
  - [x] Set `duration: const Duration(milliseconds: 300)`, `curve: Curves.easeInOut`
  - [x] Set `themeMode: ThemeMode.light` — let `AnimatedTheme` drive the actual theme
  - [ ] `AnimatedTheme.data` switches between `AppTheme.defaultTheme` and `AppTheme.darkTheme`
  - [ ] Verify smooth transition on dark mode toggle

- [x] Task 4: Run full validation (AC: 4)
  - [x] `flutter analyze` — zero errors
  - [x] `flutter test` — all existing tests pass with zero regressions

## Dev Notes

### Problem Statement

From the UX DESIGN.md, tag category contrast ratios against dark scaffold `#303030`:

| Category | Foreground | Contrast on #303030 | Status |
|----------|-----------|---------------------|--------|
| general | #6F8F0E | 3.3:1 | ⚠️ FAIL |
| artist | #393F85 | 4.1:1 | ⚠️ FAIL |
| rating | #267EAD | 4.7:1 | ✅ PASS |
| character | #2D8677 | 4.4:1 | ⚠️ FAIL |
| oc | #9852A3 | 4.1:1 | ⚠️ FAIL |
| species | #8B552F | 3.7:1 | ⚠️ FAIL |
| body | #4E4E4E | **1.9:1** | 🔴 SEVERE |
| official | #998E1A | 3.5:1 | ⚠️ FAIL |
| fanmade | #BB5496 | 3.6:1 | ⚠️ FAIL |
| origin | #393F85 | 4.1:1 | ⚠️ FAIL |
| spoiler | #C24523 | 4.2:1 | ⚠️ FAIL |
| error | #AD263F | 3.9:1 | ⚠️ FAIL |

**11 of 12 categories fail WCAG AA (≥4.5:1).** Only `rating` passes.

### Current State of `tag_categories.dart`

```dart
// lib/config/tag_categories.dart — current structure
import 'package:flutter/material.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';

const Map<TagCategory, Color> tagBackColors = {
  // 12 entries — these stay UNCHANGED
  TagCategory.general:   Color.fromARGB(255, 208, 226, 156),
  TagCategory.artist:    Color.fromARGB(255, 185, 188, 225),
  // ... etc
};

const Map<TagCategory, Color> tagForeColors = {
  // 12 entries — these become tagForeColorsLight
  TagCategory.general:   Color.fromARGB(255, 111, 143, 14),
  TagCategory.artist:    Color.fromARGB(255, 57, 63, 133),
  // ... etc
};
```

### Target Structure After Task 1

```dart
// lib/config/tag_categories.dart — after restructuring
import 'package:flutter/material.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';

/// Background colors — unchanged, same for both themes.
/// Light enough to create visible chips against both #FFFFFF and #303030.
const Map<TagCategory, Color> tagBackColors = {
  TagCategory.general:   const Color.fromARGB(255, 208, 226, 156),
  TagCategory.artist:    const Color.fromARGB(255, 185, 188, 225),
  TagCategory.error:     const Color.fromARGB(255, 238, 177, 188),
  TagCategory.fanmade:   const Color.fromARGB(255, 239, 215, 231),
  TagCategory.rating:    const Color.fromARGB(255, 193, 215, 228),
  TagCategory.body:      const Color.fromARGB(255, 193, 193, 193),
  TagCategory.character: const Color.fromARGB(255, 181, 223, 216),
  TagCategory.oc:        const Color.fromARGB(255, 222, 197, 226),
  TagCategory.official:  const Color.fromARGB(255, 237, 230, 151),
  TagCategory.spoiler:   const Color.fromARGB(255, 244, 205, 194),
  TagCategory.species:   const Color.fromARGB(255, 230, 201, 181),
  TagCategory.origin:    const Color.fromARGB(255, 185, 188, 225),
};

/// Light-theme foreground colors — original values preserved.
/// Designed for readability against light scaffold (#FFFFFF).
const Map<TagCategory, Color> tagForeColorsLight = {
  TagCategory.general:   const Color.fromARGB(255, 111, 143, 14),
  TagCategory.artist:    const Color.fromARGB(255, 57, 63, 133),
  TagCategory.error:     const Color.fromARGB(255, 173, 38, 63),
  TagCategory.fanmade:   const Color.fromARGB(255, 187, 84, 150),
  TagCategory.rating:    const Color.fromARGB(255, 38, 126, 173),
  TagCategory.body:      const Color.fromARGB(255, 78, 78, 78),
  TagCategory.character: const Color.fromARGB(255, 45, 134, 119),
  TagCategory.oc:        const Color.fromARGB(255, 152, 82, 163),
  TagCategory.official:  const Color.fromARGB(255, 153, 142, 26),
  TagCategory.spoiler:   const Color.fromARGB(255, 194, 69, 35),
  TagCategory.species:   const Color.fromARGB(255, 139, 85, 47),
  TagCategory.origin:    const Color.fromARGB(255, 57, 63, 133),
};

/// Dark-theme foreground colors — computed for ≥4.5:1 contrast against
/// each category's [tagBackColors] entry, while maintaining hue identity.
///
/// Each value was derived by increasing the lightness and saturation of
/// the corresponding light-mode foreground, targeting WCAG AA compliance
/// against the chip background (NOT the scaffold).
const Map<TagCategory, Color> tagForeColorsDark = {
  // general: bg #D0E29C, current fg #6F8F0E → bright lime-green
  TagCategory.general:   const Color.fromARGB(255, 146, 184, 26),
  // artist: bg #B9BCE1, current fg #393F85 → bright lavender
  TagCategory.artist:    const Color.fromARGB(255, 139, 144, 224),
  // error: bg #EEB1BC, current fg #AD263F → bright rose
  TagCategory.error:     const Color.fromARGB(255, 217, 74, 106),
  // fanmade: bg #EFD7E7, current fg #BB5496 → bright magenta
  TagCategory.fanmade:   const Color.fromARGB(255, 224, 112, 176),
  // rating: bg #C1D7E4, current fg #267EAD → bright blue (already close to passing)
  TagCategory.rating:    const Color.fromARGB(255, 91, 170, 214),
  // body: bg #C1C1C1, current fg #4E4E4E → medium gray (was invisible at 1.9:1)
  TagCategory.body:      const Color.fromARGB(255, 144, 144, 144),
  // character: bg #B5DFD8, current fg #2D8677 → bright teal
  TagCategory.character: const Color.fromARGB(255, 93, 191, 171),
  // oc: bg #DEC5E2, current fg #9852A3 → bright purple
  TagCategory.oc:        const Color.fromARGB(255, 199, 122, 214),
  // official: bg #EDE697, current fg #998E1A → bright gold
  TagCategory.official:  const Color.fromARGB(255, 196, 184, 32),
  // spoiler: bg #F4CDC2, current fg #C24523 → bright coral
  TagCategory.spoiler:   const Color.fromARGB(255, 232, 108, 74),
  // species: bg #E6C9B5, current fg #8B552F → bright brown
  TagCategory.species:   const Color.fromARGB(255, 192, 120, 58),
  // origin: bg #B9BCE1, current fg #393F85 → bright lavender (same bg as artist)
  TagCategory.origin:    const Color.fromARGB(255, 139, 144, 224),
};

/// Returns the correct tag foreground color for the current theme brightness.
///
/// Usage:
/// ```dart
/// TextStyle(color: tagForeColor(tc, Theme.of(context).brightness))
/// ```
Color tagForeColor(TagCategory category, Brightness brightness) {
  return brightness == Brightness.dark
      ? tagForeColorsDark[category]!
      : tagForeColorsLight[category]!;
}

// tag lists — unchanged
const List<String> ratingTags = [ ... ];
const List<String> bodyTags = [ ... ];
const List<String> errorTags = [ ... ];
```

### DetailSheet Change (Task 2)

In `lib/widgets/detail.dart`, line 197-198:

**Before:**
```dart
child: Chip(
  label: Text(_tags[index],
      style: TextStyle(color: tagForeColors[tc])),
  backgroundColor: tagBackColors[tc],
)
```

**After:**
```dart
child: Chip(
  label: Text(_tags[index],
      style: TextStyle(color: tagForeColor(tc, Theme.of(context).brightness))),
  backgroundColor: tagBackColors[tc],
)
```

Import change: `tagForeColors` → `tagForeColor` in the import destructure.

### Theme Animation (Task 3)

In `lib/main.dart`, modify `DVApp`:

**Before:**
```dart
class DVApp extends StatelessWidget {
  const DVApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(
      builder: (context, prefModel, child) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Derpiviewer',
          theme: AppTheme.defaultTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: prefModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }
}
```

**After:**
```dart
class DVApp extends StatelessWidget {
  const DVApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(
      builder: (context, prefModel, child) {
        return AnimatedTheme(
          data: prefModel.isDarkMode ? AppTheme.darkTheme : AppTheme.defaultTheme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: MaterialApp(
            // themeMode fixed to light — AnimatedTheme drives the actual theme
            themeMode: ThemeMode.light,
            theme: AppTheme.defaultTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'Derpiviewer',
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
```

**How it works:** `AnimatedTheme` sits ABOVE `MaterialApp`. When `prefModel.isDarkMode` changes, `AnimatedTheme.data` toggles. Because `AnimatedTheme` is an `ImplicitlyAnimatedWidget`, it cross-fades between old and new `ThemeData` over 300ms. `MaterialApp` reads its theme from the inherited `Theme` provided by `AnimatedTheme`, but uses a fixed `themeMode: ThemeMode.light` to avoid conflicting animations.

**No changes to `lib/style/theme.dart` needed.** The existing `AppTheme` class and its `defaultTheme`/`darkTheme` getters are sufficient.

### Color Contrast Verification

The developer should verify contrast during implementation. Quick manual check:

```dart
// In Dart, compute contrast ratio:
import 'dart:math';

double _linearize(int component) {
  final s = component / 255.0;
  return s <= 0.04045 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4);
}

double relativeLuminance(Color c) {
  return 0.2126 * _linearize(c.red) +
         0.7152 * _linearize(c.green) +
         0.0722 * _linearize(c.blue);
}

double contrastRatio(Color bg, Color fg) {
  final l1 = relativeLuminance(bg);
  final l2 = relativeLuminance(fg);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// Verify: contrastRatio(tagBackColors[category]!, tagForeColorsDark[category]!) >= 4.5
```

If any dark foreground color fails the contrast check, adjust by increasing lightness (move closer to white) while maintaining the hue. This is a visual quality check — the story provides starting values that should be close.

### Files to Modify

| File | Change |
|------|--------|
| `lib/config/tag_categories.dart` | Split `tagForeColors` → `tagForeColorsLight` + `tagForeColorsDark`; add `tagForeColor()` helper |
| `lib/widgets/detail.dart` | Use `tagForeColor(tc, Theme.of(context).brightness)` instead of `tagForeColors[tc]` |
| `lib/main.dart` | Wrap `MaterialApp` with `AnimatedTheme` for 300ms cross-fade transition |

### Files to Create

None — modifications to existing files only.

### Preserved Behaviors (MUST NOT BREAK)

- All 12 tag categories retain their background colors and visual identity
- Tag chips remain tappable (copy tag to clipboard)
- Light theme appearance is unchanged — `tagForeColorsLight` is identical to previous `tagForeColors`
- Dark mode toggle in drawer continues to work
- Dark mode preference persists across app restarts via SharedPreferences
- FABs, AppBar, Drawer styling unchanged
- All existing tests pass

### References

- [UX DESIGN.md: Tag Category Colors](_bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/DESIGN.md#tag-category-colors) — Contrast ratio table, known issues
- [UX DESIGN.md: Dark Theme](_bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/DESIGN.md#dark-theme) — Dark mode color tokens
- [UX-DR7: Dark-mode tag color contrast fix](_bmad-output/planning-artifacts/epics.md#story-32-dark-mode-tag-contrast-fix-and-theme-transition-animation)
- [UX-DR17: Theme transition animation](_bmad-output/planning-artifacts/epics.md#story-32-dark-mode-tag-contrast-fix-and-theme-transition-animation)
- [Architecture: Project Structure](_bmad-output/planning-artifacts/architecture.md#complete-project-directory-structure) — `config/` layer location
- Current source: `lib/config/tag_categories.dart` (67 lines)
- Current source: `lib/widgets/detail.dart` (205 lines)
- Current source: `lib/main.dart` (73 lines)
- Current source: `lib/style/theme.dart` (101 lines)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (BMad dev-story workflow)

### Completion Notes List

- ✅ Task 1: Restructured `lib/config/tag_categories.dart` — renamed `tagForeColors` → `tagForeColorsLight`, added `tagForeColorsDark` with 12 WCAG AA-compliant colors (≥4.5:1 against chip backgrounds), added `tagForeColor()` helper function
- ✅ Task 2: Updated `lib/widgets/detail.dart` — changed `tagForeColors[tc]` → `tagForeColor(tc, Theme.of(context).brightness)` for theme-aware rendering
- ✅ Task 3: Updated `lib/main.dart` — wrapped `MaterialApp` with `AnimatedTheme` (300ms duration, `Curves.easeInOut`, `themeMode: ThemeMode.light`) for smooth cross-fade theme transitions
- ✅ Task 4: Full validation — `flutter analyze` shows zero errors (only pre-existing warnings/infos), all 104 tests pass with zero regressions (8 new + 96 existing)
- **Key technical decision:** Story-provided dark foreground values gave 1.7:1 contrast (way below AA). Computed correct values by preserving original hue+saturation in HSL space, reducing lightness until ≥4.5:1 contrast achieved against each chip background. Results: 6.8:1–8.3:1 (exceeds AAA level).
- `body` tag fix: old `#4E4E4E` → new dark `#2A2A2A` (1.9:1 → 8.0:1 contrast against chip background)
- `tagBackColors` unchanged — backgrounds work for both themes
- 3 files modified, 1 test file created, 0 deletions

### Code Review Fixes (2026-06-05)

- 🔴 **CRITICAL FIX — `lib/main.dart`:** Removed broken `AnimatedTheme` wrapper. `MaterialApp` internally creates its own `AnimatedTheme`/`Theme` widget that shadows any external wrapper. The outer `AnimatedTheme.data` was never visible to `Theme.of(context)`. Replaced with `MaterialApp`'s built-in `themeAnimationDuration: 300ms` + `themeAnimationCurve: Curves.easeInOut` — achieves the same smooth cross-fade correctly.
- 🟡 **FIX — `lib/config/tag_categories.dart`:** Replaced `!` null assertions in `tagForeColor()` with `?? Colors.white` / `?? Colors.black` fallbacks. Prevents runtime crash when new `TagCategory` enum values are added without updating the color maps.
- 🟡 **FIX — `lib/widgets/detail.dart`:** Added `?? Colors.grey` null guard for `tagBackColors[tc]`. Prevents invisible chips (null backgroundColor) when maps are out of sync.
- 🔵 **CLEANUP — `test/config/tag_categories_test.dart`:** Replaced hand-rolled `_linearize()` + `relativeLuminance()` with Flutter SDK's `Color.computeLuminance()`. Removed `dart:math` dependency (kept `max`/`min` only).
- ✅ **Validation post-fix:** `flutter analyze` — zero errors (93 pre-existing warnings/infos). `flutter test` — 104/104 pass, zero regressions.

### File List

| File | Action |
|------|--------|
| `lib/config/tag_categories.dart` | Modified — renamed `tagForeColors` → `tagForeColorsLight`, added `tagForeColorsDark` + `tagForeColor()` helper (+ null-safe fallback) |
| `lib/widgets/detail.dart` | Modified — `tagForeColors[tc]` → `tagForeColor(tc, Theme.of(context).brightness)` (+ null guard for tagBackColors) |
| `lib/main.dart` | Modified — removed broken AnimatedTheme wrapper, restored dynamic themeMode, added themeAnimationDuration/Curve for 300ms transition |
| `test/config/tag_categories_test.dart` | Created — 8 tests for dual-theme colors, WCAG AA contrast, helper function, body fix verification (+ SDK luminance method) |

### Change Log

- 2026-06-05: Story 3.2 implementation — dark mode tag contrast fix (WCAG AA ≥4.5:1), theme transition animation (MaterialApp 300ms easeInOut), 8 new tests, zero regressions
- 2026-06-05: Code review fixes — removed broken AnimatedTheme (shadowed by MaterialApp), null-safe fallbacks, SDK luminance method, 104/104 tests pass
