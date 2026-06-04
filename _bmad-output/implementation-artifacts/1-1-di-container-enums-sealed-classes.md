---
baseline_commit: ea467f30f36c8cfdacdbcc0acc9631b08ae3764f
---
# Story 1.1: Set Up DI Container, Extract Enums, and Define Sealed Classes

Status: done

## Story

As a developer,
I want a get_it DI container, pure enums extracted from the God file, and Result/ViewState/FailureType sealed classes,
so that all future code follows consistent dependency injection and state management patterns.

## Acceptance Criteria

1. **Given** the project has run `flutter pub get` with `get_it` dependency added
   **When** `configureDependencies()` is called during main() initialization
   **Then** the get_it container is configured for future state registration (Repository, ApiStrategy, Dio instances)
   **And** `flutter analyze` passes with zero errors

2. **Given** the `lib/core/domain/` directory structure has been created
   **When** a developer imports `import 'package:derpiviewer/core/domain/enums/booru.dart';`
   **Then** the `Booru` enum is accessible with zero Flutter or config dependencies
   **And** all 6 enum files (booru, sort_field, sort_direction, content_format, tag_category, size) are independently importable
   **And** the original enums in `lib/enums.dart` have been removed

3. **Given** `lib/core/domain/result.dart` exists
   **When** a developer calls a `Future<Result<List<ImageEntity>>>` method
   **Then** `Result<T>` sealed class supports two variants: `Success<T>(T data)` and `Failure<T>(String message, FailureType type, Object? error, StackTrace? stackTrace)`
   **And** `FailureType` enum contains: network, notFound, timeout, api, deserialization

4. **Given** `lib/core/domain/view_state.dart` exists
   **When** a Provider exposes `ViewState<T> get state`
   **Then** `ViewState<T>` sealed class supports three variants: `LoadingState<T>`, `SuccessState<T>(T data)`, `FailureState<T>(String message, FailureType type)`
   **And** UI can render all three states using exhaustive switch

5. **Given** the DI container is initialized
   **When** the app starts
   **Then** `getIt.isRegistered<ImageRepository>()` returns false (interfaces not registered yet — that happens in Story 1.2+1.3)
   **And** the container is ready for lazy registration in subsequent stories

## Tasks / Subtasks

- [x] Task 1: Add `get_it` to pubspec.yaml (AC: 1)
  - [x] Add `get_it: ^8.0.0` to dependencies
  - [x] Run `flutter pub get`
- [x] Task 2: Create `lib/core/domain/enums/` directory with 6 pure enum files (AC: 2)
  - [x] `booru.dart` — Booru enum (derpi, trixie, pony, twi, fur, ponerpics, mane)
  - [x] `sort_field.dart` — SortField enum (wilsonScore, created, updated, firstSeen, score, relevance, width, height, comments, tagCount)
  - [x] `sort_direction.dart` — SortDirection enum (desc, asc)
  - [x] `content_format.dart` — ContentFormat enum (gif, jpg, jpeg, png, svg, webm, mp4)
  - [x] `tag_category.dart` — TagCategory enum (general, artist, rating, character, oc, species, body, official, fanmade, origin, spoiler, error)
  - [x] `size.dart` — Size enum (full, large, medium, small, thumb, thumbSmall, thumbTiny)
- [x] Task 3: Create `lib/core/domain/failure_type.dart` (AC: 3)
  - [x] FailureType enum: network, notFound, timeout, api, deserialization
- [x] Task 4: Create `lib/core/domain/result.dart` (AC: 3)
  - [x] Dart 3 sealed class with Success<T> and Failure<T> variants
- [x] Task 5: Create `lib/core/domain/view_state.dart` (AC: 4)
  - [x] Dart 3 sealed class with LoadingState<T>, SuccessState<T>, FailureState<T>
- [x] Task 6: Create `lib/core/di/injection_container.dart` (AC: 1, 5)
  - [x] `configureDependencies()` function with get_it setup
  - [x] Placeholder registrations for future Repository/Strategy/Dio
- [x] Task 7: Update `lib/main.dart` to call `configureDependencies()` (AC: 1)
  - [x] Call before runApp, after WidgetsFlutterBinding.ensureInitialized
- [x] Task 8: Clean up `lib/enums.dart` (AC: 2)
  - [x] Remove extracted enums, keep only ConstStrings config (will be further split in Epic 3)
  - [x] Update all imports across the project to point to new enum locations
  - [x] Verify `flutter analyze` passes

## Dev Notes

### Architecture Constraints (MUST FOLLOW)

- **DI boundary rule:** `getIt<T>()` calls are ONLY allowed in `main.dart` Provider `create:` callbacks and `configureDependencies()`. NEVER in widgets, providers, or dialogs.
- **Domain layer purity:** Files in `lib/core/domain/` must NOT import Flutter or any `ui/` files. Pure Dart only.
- **Naming:** `snake_case` filenames, `PascalCase` class names. No `I` prefix on interfaces.
- **No freezed:** Architecture decisions committee (Party Mode review) explicitly removed freezed. Use manual `const` constructors and `==` operators.
- **Dart 3 sealed:** Use `sealed class` (Dart 3.8+ feature) for Result and ViewState — enables exhaustive `switch` at call sites.

### Files to Create

| File | Purpose |
|------|---------|
| `lib/core/domain/enums/booru.dart` | Booru enum (7 values) |
| `lib/core/domain/enums/sort_field.dart` | SortField enum (10 values) |
| `lib/core/domain/enums/sort_direction.dart` | SortDirection enum (2 values) |
| `lib/core/domain/enums/content_format.dart` | ContentFormat enum (7 values) |
| `lib/core/domain/enums/tag_category.dart` | TagCategory enum (12 values) |
| `lib/core/domain/enums/size.dart` | Size enum (7 values) |
| `lib/core/domain/failure_type.dart` | FailureType enum (5 values) |
| `lib/core/domain/result.dart` | `Result<T>` sealed class |
| `lib/core/domain/view_state.dart` | `ViewState<T>` sealed class |
| `lib/core/di/injection_container.dart` | get_it container setup |

### Files to Modify

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `get_it: ^8.0.0` |
| `lib/main.dart` | Add `configureDependencies()` call before runApp |
| `lib/enums.dart` | Remove extracted enums; update all cross-file imports throughout the project |

### Current State of `lib/enums.dart` (what to extract)

The file currently (255 lines) contains:
- **6 enums** → Extract to `core/domain/enums/` (Task 2)
- **ConstStrings class** → Keep in `lib/config/` for now (will be further split in Epic 3 into `booru_config.dart`, `tag_categories.dart`, `constants.dart`)
- **BuildContext-dependent methods** (`getSfs`, `getSds`) → These depend on l10n; keep in place for now, refactored in Epic 3

### Code Patterns

**Result<T> sealed class:**
```dart
// lib/core/domain/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final FailureType type;
  final Object? error;
  final StackTrace? stackTrace;
  const Failure(this.message, {required this.type, this.error, this.stackTrace});
}
```

**ViewState<T> sealed class:**
```dart
// lib/core/domain/view_state.dart
sealed class ViewState<T> {
  const ViewState();
}

class LoadingState<T> extends ViewState<T> {
  const LoadingState();
}

class SuccessState<T> extends ViewState<T> {
  final T data;
  const SuccessState(this.data);
}

class FailureState<T> extends ViewState<T> {
  final String message;
  final FailureType type;
  const FailureState(this.message, {required this.type});
}
```

**DI container:**
```dart
// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Repository implementations — registered in later stories
  // getIt.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl(...));
  // getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(...));
  // ApiStrategy instances — registered in later stories
  // Dio instances — registered in later stories
}
```

**main.dart integration:**
```dart
// lib/main.dart — add after WidgetsFlutterBinding.ensureInitialized()
await configureDependencies();
```

### Import Update Pattern

All existing imports pointing to `package:derpiviewer/enums.dart` for enums must be updated:
```dart
// Before:
import 'package:derpiviewer/enums.dart';
// After (import only what's needed):
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';
```

Files that import from `enums.dart`:
- `lib/api/clients.dart` — uses Booru, ConstStrings
- `lib/api/do.dart` — uses Booru, ContentFormat, ConstStrings, SortDirection, SortField
- `lib/helpers/helper.dart` — uses Booru, TagCategory, ConstStrings
- `lib/helpers/connect.dart` — no enum imports (just Dio)
- `lib/helpers/db.dart` — uses Booru
- `lib/models/pref_model.dart` — uses Booru, ConstStrings, SortDirection, SortField
- `lib/models/search_model.dart` — uses Booru, ConstStrings, ContentFormat, SortDirection, SortField, Size
- `lib/models/trending_model.dart` — uses SortDirection
- `lib/models/fav_model.dart` — uses Booru, ContentFormat, Size
- `lib/pages/home_page.dart` — uses Booru, ConstStrings
- `lib/pages/search_page.dart` — uses ConstStrings
- `lib/pages/result_page.dart` — no direct enum import
- `lib/pages/fav_page.dart` — uses Booru, ConstStrings
- `lib/pages/gallery.dart` — uses ContentFormat, Size
- `lib/widgets/image_grid.dart` — uses Booru
- `lib/widgets/detail.dart` — uses Booru, ConstStrings, TagCategory
- `lib/widgets/dialogs.dart` — uses Booru, ConstStrings, SortDirection, SortField, Size
- `lib/widgets/toolbar.dart` — uses ContentFormat, ConstStrings, Size
- `lib/widgets/icons.dart` — no enum imports

**Strategy:** After removing enums from `enums.dart`, keep ConstStrings in that file (temporarily — Epic 3 splits it). Update ALL imports. Run `flutter analyze` until clean.

### Testing Not Required (Deferred)

This story establishes infrastructure patterns. Dedicated tests for Result<T>, ViewState<T>, and DI container happen in Story 1.6. The AC for this story is `flutter analyze` pass — compile-time verification is sufficient.

### References

- Architecture Decision Document: `_bmad-output/planning-artifacts/architecture.md` — DI Boundary Rule, Result/ViewState Pattern, Naming Conventions
- Epic 1 Context: `_bmad-output/planning-artifacts/epics.md` — Story 1.1 requirements
- Project Docs: `docs/architecture.md` — Current architecture analysis, dependency map
- Current source: `lib/enums.dart` (255 lines) — source of enums to extract

## Dev Agent Record

### Agent Model Used

Claude Opus 4.8 (BMad dev-story workflow)

### Debug Log

- 2026-06-04: Resolved workflow configuration via customize.toml (no team/user overrides).
- 2026-06-04: Baseline commit captured: `ea467f3`.
- 2026-06-04: All 8 tasks completed. `flutter analyze` passes with zero errors.
- 2026-06-04: Pre-existing warnings (18) are unchanged — none introduced by this story.
- Import strategy: Files that use `ConstStrings` keep `enums.dart` import; others switched to direct enum imports. `Size` enum import was critical to avoid collision with Flutter's `Size` class.

### Completion Notes List

**Task 1:** Added `get_it: ^8.0.0` to `pubspec.yaml`. `flutter pub get` installed v8.3.0 successfully.

**Task 2:** Created 6 pure enum files under `lib/core/domain/enums/`. Each file is independently importable with zero Flutter dependencies. Values match the original definitions in `lib/enums.dart` exactly.

**Task 3:** Created `lib/core/domain/failure_type.dart` with 5 variants: network, notFound, timeout, api, deserialization.

**Task 4:** Created `lib/core/domain/result.dart` — Dart 3 sealed class `Result<T>` with `Success<T>(T data)` and `Failure<T>(String message, FailureType type, Object? error, StackTrace? stackTrace)`.

**Task 5:** Created `lib/core/domain/view_state.dart` — Dart 3 sealed class `ViewState<T>` with `LoadingState<T>`, `SuccessState<T>(T data)`, and `FailureState<T>(String message, FailureType type)`.

**Task 6:** Created `lib/core/di/injection_container.dart` with `configureDependencies()` function and `getIt` instance. Placeholder registrations commented out for future stories.

**Task 7:** Updated `lib/main.dart` — added `import` for injection_container and `await configureDependencies()` call after `WidgetsFlutterBinding.ensureInitialized()` and other initialization.

**Task 8:** Removed 6 enum definitions from `lib/enums.dart` (Booru, SortField, SortDirection, Size, ContentFormat, TagCategory). Added direct imports for the new enum files needed by `ConstStrings` (booru, sort_field, sort_direction, tag_category). Updated imports in 16 files across the project — 4 files switched to direct enum imports (no ConstStrings needed), 12 files kept `enums.dart` import plus added specific enum imports. `flutter analyze` passes with zero errors.

### File List

**New Files:**
- `lib/core/domain/enums/booru.dart`
- `lib/core/domain/enums/sort_field.dart`
- `lib/core/domain/enums/sort_direction.dart`
- `lib/core/domain/enums/content_format.dart`
- `lib/core/domain/enums/tag_category.dart`
- `lib/core/domain/enums/size.dart`
- `lib/core/domain/failure_type.dart`
- `lib/core/domain/result.dart`
- `lib/core/domain/view_state.dart`
- `lib/core/di/injection_container.dart`

**Modified Files:**
- `pubspec.yaml` — Added `get_it: ^8.0.0`
- `lib/main.dart` — Added `configureDependencies()` call
- `lib/enums.dart` — Removed 6 enum definitions, added new enum imports
- `lib/api/clients.dart` — Added `booru.dart` import
- `lib/api/do.dart` — Added booru, content_format, sort_direction, sort_field imports
- `lib/helpers/helper.dart` — Added booru, tag_category imports
- `lib/helpers/download.dart` — Added booru, content_format imports
- `lib/helpers/db.dart` — Replaced enums.dart with booru.dart import
- `lib/models/pref_model.dart` — Added booru, sort_direction, sort_field, size imports
- `lib/models/search_model.dart` — Added booru, content_format, size imports
- `lib/models/trending_model.dart` — Added sort_direction import
- `lib/models/fav_model.dart` — Replaced enums.dart with booru, content_format, size imports
- `lib/pages/home_page.dart` — No import changes needed (uses ConstStrings only)
- `lib/pages/fav_page.dart` — No import changes needed (uses ConstStrings only)
- `lib/pages/gallery.dart` — Replaced enums.dart with content_format import
- `lib/widgets/image_grid.dart` — Removed unused enums.dart import
- `lib/widgets/detail.dart` — No import changes needed (uses ConstStrings only, TagCategory via helper)
- `lib/widgets/dialogs.dart` — Added booru, sort_direction, sort_field, size imports
- `lib/widgets/toolbar.dart` — Added content_format, size imports

## Change Log

- 2026-06-04: Story 1.1 implementation complete. Added get_it DI container, extracted 6 enums to `lib/core/domain/enums/`, created Result/ViewState/FailureType sealed classes, cleaned up `lib/enums.dart`, updated all cross-file imports.

## Senior Developer Review (AI)

**Review Date:** 2026-06-04
**Review Outcome:** Approved (all findings resolved)
**Reviewers:** Blind Hunter (adversarial), Edge Case Hunter, Acceptance Auditor

### Review Findings

#### Decision Needed

- [x] [Review][Decision] **Size enum name collision with Flutter's dart:ui.Size** — **Resolved: (A)** Renamed `Size` → `ImageSize` in `lib/core/domain/enums/image_size.dart`. Updated imports in `pref_model.dart`, `search_model.dart`, `dialogs.dart`, `toolbar.dart`, `fav_model.dart`. Deleted old `size.dart`. `flutter analyze` passes with zero errors. **Severity: High**

- [x] [Review][Decision] **getIt instance exported globally with no access enforcement** — **Resolved: (A)** Made `_getIt` private. Added public `resolve<T>()` accessor function. Updated comments to reflect new API. **Severity: Medium**

- [x] [Review][Decision] **FailureType enum missing `unknown` variant** — **Resolved: (A)** Added `unknown` to FailureType enum in `lib/core/domain/failure_type.dart`. **Severity: Medium**

- [x] [Review][Decision] **Failure<T> and FailureState<T> constructors use named `type` instead of positional** — **Resolved: (A)** Changed `Failure(this.message, this.type, ...)` and `FailureState(this.message, this.type)` to positional params matching spec. **Severity: Medium**

#### Patch

- [x] [Review][Patch] **Success<T>, Failure<T>, SuccessState<T>, FailureState<T> lack `==` and `hashCode` overrides** — **Fixed.** Added `==` and `hashCode` to all four classes in `lib/core/domain/result.dart` and `lib/core/domain/view_state.dart`.

#### Deferred (Pre-existing)

- [x] [Review][Defer] SearchModel._fetchResult shadows `over` class field causing infinite API calls — `lib/models/search_model.dart:36`
- [x] [Review][Defer] Unhandled exceptions from fetchMore in Provider update callbacks — `lib/main.dart:25-37`
- [x] [Review][Defer] .gitignore entry ".gitignore" self-ignores — `.gitignore:54`
- [x] [Review][Defer] _bmad pattern doesn't match _bmad-output/ directory — `.gitignore:53`
- [x] [Review][Defer] ConstStrings.format/mime lists coupled to ContentFormat enum index ordering — `lib/enums.dart`, `lib/api/do.dart`
- [x] [Review][Defer] ContentFormat.values[-1] RangeError on unknown API format — `lib/api/do.dart:78,101`
- [x] [Review][Defer] downloadFile switch default leaves bs null — `lib/helpers/download.dart:55-76`
- [x] [Review][Defer] helper.dart appendClipboard fires-and-forgets Future — `lib/helpers/helper.dart:7`
- [x] [Review][Defer] PrefModel getPref() uses imageSize.index as fallback for all size types — `lib/models/pref_model.dart:82-85`
- [x] [Review][Defer] _pageController.page! forced unwrap may crash — `lib/pages/gallery.dart:67,138,153`
