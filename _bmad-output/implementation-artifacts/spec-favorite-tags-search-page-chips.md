---
title: 'Favorite Tags Search Page Chips'
type: 'feature'
created: '2026-06-06'
status: 'done'
baseline_commit: '3abdc916ef9d0d4d222e9dff80cd3e6abb74ce05'
context:
  - '{project-root}/_bmad-output/implementation-artifacts/spec-favorite-tags-data-layer.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Users have saved favorite tags via the data layer, but the search page body is empty (`Container()`) — there is no way to browse, reuse, or manage favorite tags from the search UI. Users must retype every tag manually.

**Approach:** Add a favorite tags chip list to the search page body, styled like image-detail tag chips. Clicking a chip appends the tag to the search input (`,`-separated). Long-pressing a chip removes it from favorites. An add button opens a dialog to save new favorite tags.

## Boundaries & Constraints

**Always:**
- Use existing `FavoriteTagsRepository` resolved via `resolve<>()` — already registered as lazy singleton in DI
- Follow existing UI patterns: `Chip` inside `Wrap`, `StatelessWidget` dialogs, `AppLocalizations` i18n
- Chip visual style: use `getTagCategory(tag, 0, Booru.derpibooru)` for per-category background/foreground coloring, same as image detail chips in `detail.dart`. Note: `tagid` and `booru` parameters of `getTagCategory` are unused by the function body — they only check static lists and prefix patterns — so any default values work
- Load favorite tags in `initState` + refresh via `setState` after add/delete
- i18n: add keys to both `app_en.arb` and `app_zh.arb`, plus abstract + concrete implementations

**Ask First:**
- (none — all design decisions have conventional defaults)

**Never:**
- No per-booru scoping (matches data layer's cross-booru design)
- No Chip styling divergence from detail.dart — reuse `getTagCategory` + `tagBackColors`/`tagForeColor` exactly
- No reordering, renaming, or bulk operations on favorite tags
- No migration or schema changes — data layer is complete and untouched
- Do not add `Consumer`/`ChangeNotifier` wrapping around `FavoriteTagsRepository` — use manual `setState` refresh pattern

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Page load with favorites | DB has 3 tags: `safe`, `oc:sonata`, `solo` | Wrap with 3 Chips rendered in body | Repository returns Failure → show empty state |
| Page load with no favorites | DB has 0 tags | Show l10n empty-state message | N/A |
| Tap chip | User taps `safe` chip, input is `oc:sonata` | Input becomes `oc:sonata, safe` | N/A |
| Tap chip (empty input) | User taps `solo` chip, input is empty | Input becomes `solo` (no leading comma) | N/A |
| Tap chip (duplicate tag) | User taps `safe`, input already has `safe, solo` | Input unchanged (avoid duplicate) | N/A |
| Long-press chip | User long-presses `safe` | Tag removed from DB, chip disappears from list, show toast | Repository returns Failure → show error toast |
| Add tag dialog — submit | User enters `twilight sparkle` and confirms | Tag saved via repository, chip appears in list, toast shown | Repository returns Failure → show error toast, dialog stays open |
| Add tag dialog — empty | User confirms with empty input | Dialog closes without action | N/A |
| Add tag dialog — duplicate | User enters existing tag `safe` | Repository ignores (INSERT OR IGNORE), dialog closes, no duplicate chip appears | N/A |
| Add tag dialog — cancel | User taps Cancel | Dialog closes, no change | N/A |

</frozen-after-approval>

## Code Map

- `lib/pages/search_page.dart` — add favorite tags `Wrap`+`Chip` list in body, inject repository, handle tap/long-press/add-refresh
- `lib/ui/widgets/dialogs/add_favorite_tag_dialog.dart` — **NEW** `StatelessWidget` dialog with `TextField` + confirm/cancel actions
- `lib/l10n/app_en.arb` — add ~6 new English strings
- `lib/l10n/app_zh.arb` — add ~6 new Chinese strings
- `lib/l10n/app_localizations.dart` — add new getter/method declarations
- `lib/l10n/app_localizations_en.dart` — add new getter/method implementations
- `lib/l10n/app_localizations_zh.dart` — add new getter/method implementations

## Tasks & Acceptance

**Execution:**
- [x] `lib/l10n/app_en.arb` + `lib/l10n/app_zh.arb` — add l10n keys: `searchFavoriteTagsTitle`, `searchFavoriteTagsEmpty`, `searchAddFavoriteTag`, `searchAddFavoriteTagHint`, `searchTagAdded`, `searchTagDeleted` — i18n foundation
- [x] `lib/l10n/app_localizations.dart` + `lib/l10n/app_localizations_en.dart` + `lib/l10n/app_localizations_zh.dart` — add corresponding getter/method declarations and implementations — i18n codegen counterparts
- [x] `lib/ui/widgets/dialogs/add_favorite_tag_dialog.dart` — create `StatelessWidget` with `AlertDialog` containing a `TextField` + confirm/cancel `TextButton` actions; uses `FavoriteTagsRepository` to persist — add tag entry point
- [x] `lib/pages/search_page.dart` — inject `FavoriteTagsRepository`, load tags in `initState`, replace `body: Container()` with `Wrap`+`Chip` list; tap appends tag to `_textController` (`,`-separated, skip duplicates); long-press deletes tag with toast; add `IconButton` in AppBar that opens `AddFavoriteTagDialog` — core feature

**Acceptance Criteria:**
- Given the search page loads, when favorite tags exist in DB, then all tags are displayed as Chips in a Wrap in the body
- Given favorite tags are displayed, when user taps a chip, then the tag is appended to the search input with `, ` separator (or directly if input is empty; skipped if already present)
- Given favorite tags are displayed, when user long-presses a chip, then the tag is removed from DB and the chip disappears from the list
- Given the add button is tapped, when dialog opens and user enters a tag name and confirms, then the tag is saved and appears in the chip list
- Given `flutter analyze` runs, when it completes, then zero errors on all changed files
- Given `flutter test` runs, when it completes, then all existing tests still pass

## Design Notes

### Chip tap: append to input with dedup

```dart
void _appendTagToInput(String tag) {
  final current = _textController.text;
  final tags = current.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toSet();
  if (tags.contains(tag)) return;          // already in input → no-op
  final sep = current.isEmpty ? '' : ', ';
  _textController.text = '$current$sep$tag';
}
```

### Long-press: delete from favorites

Follow existing `toast`+`setState` pattern. On failure, show error via `Fluttertoast.showToast` (same as `detail.dart` and other widgets).

### Chip styling: category-colored (matching detail.dart)

```dart
final tc = getTagCategory(tag, 0, Booru.derpi);
Chip(
  label: Text(tag,
      style: TextStyle(color: tagForeColor(tc, Theme.of(context).brightness))),
  backgroundColor: tagBackColors[tc] ?? Colors.grey,
)
```

`tagid` (0) and `booru` (any) are dummies — `getTagCategory` only checks static lists and prefix patterns; the parameters exist in the signature but are never read.

### Empty state

When `_favoriteTags` list is empty after load, display a centered `Text` widget with the l10n empty-state string, matching the `favouritesEmptyTitle`/`favouritesEmptySubtitle` pattern from the favorites page.

## Spec Change Log

### Loopback 1 — 2026-06-06

**Triggering findings:** Three parallel reviews (Blind Hunter, Edge Case Hunter, Acceptance Auditor) identified 8 patch-level issues. No intent_gap or bad_spec — no spec amendment needed.

**Patches applied (code-only):**
1. Converted `AddFavoriteTagDialog` from StatelessWidget to StatefulWidget — fixes TextEditingController leak, mounted guard, enables debounce
2. Added `_isSubmitting` flag with CircularProgressIndicator — prevents rapid-tap concurrent submits
3. Added Failure toast in `_loadFavoriteTags` — previously silent
4. Added `!_favoriteTags.contains(tag)` guard in `_showAddDialog` — prevents duplicate chip on re-add
5. Strip trailing comma before append — prevents double-comma in input
6. Switch to `TextEditingValue` for atomic text+selection mutation — prevents cursor clobber
7. Added `ValueKey` to chip GestureDetectors — prevents full rebuild on every setState

**KEEP instructions:**
- KEEP Wrap+Chip+GestureDetector pattern with category coloring via getTagCategory
- KEEP `, ` separator dedup logic with toSet()
- KEEP IconButton(Icons.add) in AppBar actions
- KEEP resolve<FavoriteTagsRepository>() + manual setState refresh
- KEEP all 6 i18n keys and implementations

## Verification

**Commands:**
- `flutter analyze` — expected: zero errors, zero warnings on changed files
- `flutter test` — expected: all existing tests pass (no regressions)

## Suggested Review Order

**Entry point — body rewrite with chip interaction logic**

- Core feature: body replaced with Wrap+Chip list, tap-to-append, long-press-to-delete, empty state
  [`search_page.dart:184`](../../lib/pages/search_page.dart#L184)

- Tag append logic: comma-separated dedup with trailing-comma cleanup and atomic TextEditingValue mutation
  [`search_page.dart:70`](../../lib/pages/search_page.dart#L70)

- Tag delete logic: async DB remove with mounted guard and toast feedback
  [`search_page.dart:85`](../../lib/pages/search_page.dart#L85)

- Add dialog trigger + optimistic local insert with duplicate guard
  [`search_page.dart:100`](../../lib/pages/search_page.dart#L100)

- Favorite tags loaded in initState via resolve<>()
  [`search_page.dart:58`](../../lib/pages/search_page.dart#L58)

**Add tag dialog — StatefulWidget with submit guard**

- Dialog structure: AlertDialog + TextField with _isSubmitting debounce and loading spinner
  [`add_favorite_tag_dialog.dart:1`](../../lib/ui/widgets/dialogs/add_favorite_tag_dialog.dart#L1)

- Async submit: resolve<>() addTag, mounted check, Success/Failure branching
  [`add_favorite_tag_dialog.dart:65`](../../lib/ui/widgets/dialogs/add_favorite_tag_dialog.dart#L65)

**i18n — new localization keys**

- English strings: 6 new keys for title, empty state, dialog, and toast messages
  [`app_en.arb:93`](../../lib/l10n/app_en.arb#L93)

- Chinese translations: matching 6 keys
  [`app_zh.arb:104`](../../lib/l10n/app_zh.arb#L104)
