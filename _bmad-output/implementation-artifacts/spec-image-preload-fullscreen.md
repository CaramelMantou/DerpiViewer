---
title: 'Image Preload in Fullscreen Gallery'
type: 'feature'
created: '2026-06-06'
status: 'done'
baseline_commit: '570894a5b7a5dc220201a31d5188cb24d9df7aac'
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** In fullscreen gallery mode, switching to the next image triggers a network load each time, creating a visible loading spinner and disrupting the browsing flow. The user must wait for each image to download before viewing it.

**Approach:** After each page change in the gallery viewer, proactively call `precacheImage()` with a `CachedNetworkImageProvider` for the immediate next index (current + 1). Track a generation counter to detect and ignore stale preloads from rapidly-skipped intermediate images. Skip preloading entirely when the next item is a video (webm/mp4) or when already at the last item.

## Boundaries & Constraints

**Always:**
- Only preload index = currentPageIndex + 1 (the immediate next image)
- Only preload when `getItemFormat(nextIndex)` is NOT webm or mp4
- Use the existing `ImageCacheManager()` as the cache manager for the provider
- Use `_model.getPref().imageSize` to select the same URL quality the user already configured for fullscreen viewing
- Increment an `_preloadGeneration` counter every time a new preload starts; ignore completion of stale generations
- Trigger preloading from `_handlePageChange()`, which already fires on every page transition (swipe + slideshow)
- Preload failures must be silent — log nothing, throw nothing, do not affect navigation

**Ask First:**
- None — the scope is narrow and well-defined.

**Never:**
- Do NOT preload videos (webm, mp4)
- Do NOT preload more than 1 image ahead
- Do NOT preload the previous image (index - 1)
- Do NOT preload in grid/thumbnail view — fullscreen gallery only
- Do NOT change the caching infrastructure (`ImageCacheManager`, `VideoCacheManager`, `flutter_cache_manager` config)
- Do NOT add new dependencies to pubspec.yaml

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Happy path: view image, next is image | currentIndex=2, item[2]=jpg, item[3]=png | `precacheImage()` called for index 3 with `ImageCacheManager()` | Silent on failure |
| Next item is video (webm) | currentIndex=2, item[3].format=webm | No preload triggered; `getItemFormat(3)` check returns early | N/A |
| Next item is video (mp4) | currentIndex=2, item[3].format=mp4 | No preload triggered; `getItemFormat(3)` check returns early | N/A |
| At last item | currentIndex == itemCount - 1 | No preload triggered; bounds check returns early | N/A |
| Rapid swipe (skip 2+ images) | User swipes from 2→3→4 quickly; gen=1 for idx3, then gen=2 for idx4 | Preload for idx3 starts (gen=1), then preload for idx4 starts (gen=2). When gen=1 completes, it sees `_preloadGeneration==2` and is ignored. | Stale result silently discarded |
| Empty URL | getItemUrl(nextIndex) returns "" | No preload triggered; empty check returns early | N/A |
| Context disposed (user exits gallery) | `precacheImage()` in flight, widget unmounted | Generation counter ignored; no crash because no `setState` is called on completion | Handled by generation counter — stale completions are no-ops |

</frozen-after-approval>

## Code Map

- `lib/pages/gallery.dart` — **PRIMARY**: `GalleryView` widget. Add `_preloadGeneration` counter and `_preloadNextImage(int currentIndex)` method. Call it from `_handlePageChange()` after updating the toolbar controller. The `_handlePageChange` method already has access to `currentPageIndex` via `_pageController.page!.round()`.
- `lib/core/domain/search_interface.dart` — **READ-ONLY**: Provides `getItemFormat(index)`, `getItemUrl(index, ImageSize)`, `getItemCount()` — all already used by the gallery. No changes needed.
- `lib/core/domain/enums/content_format.dart` — **READ-ONLY**: `ContentFormat.webm` and `ContentFormat.mp4` identify videos to skip.
- `lib/core/domain/enums/image_size.dart` — **READ-ONLY**: `ImageSize` enum used with `getPref().imageSize` to get the right URL.
- `lib/helpers/cache_helper.dart` — **READ-ONLY**: `ImageCacheManager()` used as the `cacheManager` parameter for `CachedNetworkImageProvider`.

## Tasks & Acceptance

**Execution:**
- [x] `lib/pages/gallery.dart` — Add `int _preloadGeneration = 0` field and `Future<void> _preloadNextImage(int currentIndex)` async method. Inside: compute `nextIndex = currentIndex + 1`, early-return if out of bounds or format is video or URL is empty. Increment `_preloadGeneration`, capture its value, call `precacheImage(CachedNetworkImageProvider(url, cacheManager: ImageCacheManager()), context)`, then check generation after await. Call `_preloadNextImage(currentPageIndex)` at the end of `_handlePageChange()`.

**Acceptance Criteria:**
- Given the user is viewing an image in fullscreen gallery, when the next item is an image, then `precacheImage()` is triggered for index+1 and the image is in cache before the user swipes to it
- Given the user is viewing an image in fullscreen gallery, when the next item is a video (webm/mp4), then no preload is initiated
- Given the user rapidly swipes from index 2 to 3 to 4, when the preload for index 3 completes after index 4's preload has started, then index 3's completion is silently ignored (generation counter mismatch)
- Given the user is at the last image in the gallery, when `_handlePageChange` fires, then no preload is attempted (out-of-bounds early return)

## Design Notes

**Why `precacheImage()` instead of `ImageProvider.resolve()` directly:**
`precacheImage()` is Flutter's idiomatic API for warming the image cache. It handles the `ImageStream` lifecycle correctly and uses the same `ImageCache` that `CachedNetworkImage` reads from at render time. Using `resolve()` manually would duplicate what `precacheImage` already does.

**Why a generation counter instead of stream cancellation:**
`CachedNetworkImageProvider` delegates HTTP fetching to `flutter_cache_manager`, which uses its own internal download queue. Truly cancelling the HTTP request would require plumbing `CancelToken` through multiple layers. The generation counter achieves the same user-facing goal (no wasted memory/CPU decoding skipped images) with zero architectural changes. The disk-cache write for a skipped intermediate image is harmless — it may even help on a return visit.

**Why not use `didChangeDependencies` or `initState`:**
These lifecycle methods fire once or on dependency changes, not on page transitions. `_handlePageChange()` already fires on every navigation event (swipe, slideshow timer, programmatic `nextPage()`), making it the single correct integration point.

## Verification

**Commands:**
- `flutter analyze lib/pages/gallery.dart` — expected: no new warnings or errors
- `flutter test` — expected: all existing tests still pass; no regressions

**Manual checks (if no CLI):**
- Open a search result with mixed images and videos. Swipe forward slowly — verify the next image loads instantly (no spinner). Swipe to a video — verify the video still plays as before. Rapidly swipe past 3+ images — verify no crashes or memory spikes. Use slideshow mode — verify preloading works during automatic advancement.

## Suggested Review Order

- Entry point: the new preload method — bounds check → format filter → URL fetch → generation counter → `precacheImage` → mounted guard → stale check
  [`gallery.dart:165`](../../lib/pages/gallery.dart#L165)

- Integration point: `_handlePageChange` — triggers preload only when rounded page index actually changes, after toolbar update
  [`gallery.dart:151`](../../lib/pages/gallery.dart#L151)

- Field declaration: `_preloadGeneration` counter — tracks which preload is current for stale-result suppression
  [`gallery.dart:36`](../../lib/pages/gallery.dart#L36)

## Spec Change Log

- **2026-06-06 (review loopback 1):** Code review found three patch-level issues. Guards (`getItemFormat`, `getItemUrl`) moved inside try block to prevent uncaught exceptions from listener callback. Added `mounted` check before `precacheImage` to guard against disposed context. Changed `catch (_)` to `on Exception` to avoid swallowing `Error` subtypes. Same post-await stale check preserved. KEEP: generation counter pattern, `_handlePageChange` integration point, format-based video skip logic.
