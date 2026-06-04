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
