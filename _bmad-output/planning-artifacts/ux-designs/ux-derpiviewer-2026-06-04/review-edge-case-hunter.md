# Edge Case Hunter Review — derpiviewer

## Overall verdict

The EXPERIENCE.md and DESIGN.md documents are thorough in their as-built reverse-engineering, but they surface a codebase that handles almost none of its edge cases deliberately. Four of the seven analysis categories contain at least one critical-severity finding, and the documents themselves are transparent about several gaps (empty states, offline handling, pull-to-refresh). The most concerning pattern is silent failure: toasts confirm actions before the async operation completes, infinite scroll triggers with no stop condition, and there is no error recovery path anywhere in the documented UX.

## Findings by Category

### 边界条件 (11 findings)

- **[critical] 空搜索提交** — If the user taps the search button or keyboard submit with an empty `InputHistoryTextField`, the app pushes ResultPage with an empty query string. This could either hit the API with a meaningless request or display a broken "Searching: " AppBar title. / 当前处理: 无 / 建议: Disable search button when input is empty, or validate before navigation.

- **[critical] 搜索结果空状态** — A search that returns 0 results shows a grid with no items, no empty-state illustration, and no "no results" message. The user sees a blank page with no feedback on whether the search was valid. / 当前处理: 文档明确标注为已知缺口 / 建议: Show a centered "No results for {query}" message with suggestions (check spelling, try different terms).

- **[critical] 收藏页空状态** — When a user has 0 favorites and taps the Favorites FAB, the FavouritePage shows an empty grid with no message. First-time users or users who cleared their data would see a blank page with no guidance. / 当前处理: 文档明确标注为已知缺口 / 建议: Show "No favorites yet — tap the heart icon in the gallery to add some" with an illustration.

- **[high] Featured image 回退链缺失** — If `featuredImageUrl` is null, empty, or returns a 404, the error fallback is an unspecified "Fallback image". No mention of what this fallback is or whether it handles transient vs permanent failures differently. / 当前处理: 提到 "Fallback image" 但未说明其内容 / 建议: Define a specific fallback asset or show nothing (hide the featured section entirely) and log the error.

- **[high] 极长搜索词导致 UI 溢出** — The ResultPage AppBar shows "Searching: {query}". An extremely long query (1000+ characters) would overflow the AppBar title, either truncating unpredictably or pushing the title off-screen. / 当前处理: 无 / 建议: Truncate the query in the AppBar (e.g., `query.length > 40 ? '${query.substring(0, 40)}...' : query`).

- **[high] 空搜索词的历史记录处理** — `InputHistoryTextField` persists search history to SharedPreferences. An empty-string or whitespace-only search could be persisted as a history entry, cluttering the history list with unusable entries. / 当前处理: 无 / 建议: Validate input before persisting to history; skip empty/whitespace-only entries.

- **[high] 快速双击 FAB** — The Favorites and Search FABs are stacked in a Column with no debouncing. Double-tapping either FAB could push two instances of the same page onto the navigation stack. The user would have to press back twice to return to HomePage. / 当前处理: 无 / 建议: Disable the FAB or ignore subsequent taps while navigation is in progress (e.g., `Navigator.push` guard with a debounce flag).

- **[medium] 存储权限未授予时下载** — The download action triggers immediately without checking `WRITE_EXTERNAL_STORAGE` / `Manage storage` permission on Android. If permission is denied, the file write fails silently, but the toast "Downloaded" might still display (if toast fires before the async write completes). / 当前处理: 无 / 建议: Check storage permission at the download boundary; request if needed; show an error toast if denied.

- **[medium] 纯 emoji / 特殊字符搜索词** — Emoji and special characters are not validated or sanitized before being sent to the Derpibooru API. The API may reject certain characters, return empty results, or behave unexpectedly. / 当前处理: 无 / 建议: Sanitize/encode input; gracefully handle API errors with user-friendly messaging rather than a silent empty grid.

- **[medium] 恢复后台后状态丢失** — The app has no state restoration mechanism. If the Android OS kills the app in the background, the user returns to a fresh HomePage rather than their previous screen. No deep linking or saved state exists to restore the navigation stack. / 当前处理: 文档注明无 named routes / 建议: Implement basic state saving for the navigation stack (e.g., save last screen/index to SharedPreferences).

- **[low] 超长 tag 文本在 Chip 中溢出** — Tag chips use default Material chip shapes without explicit overflow handling. A tag string longer than ~30 characters would overflow the chip's visible area without ellipsis, potentially breaking the `Wrap` layout. / 当前处理: 无 / 建议: Set `overflow: TextOverflow.ellipsis` on tag chip labels and consider a max-width constraint.

### 状态机转换 (10 findings)

- **[critical] Infinite scroll 无终止条件** — The scroll trigger `position.pixels == position.maxScrollExtent` fires every time. When the API exhausts its result set and returns 0 new items, there is no "no more items" sentinel. The app keeps calling `fetchMore()` on every scroll to bottom, burning API quota and battery indefinitely. / 当前处理: 无 / 建议: Track `hasMore` state. Set it to `false` when the API returns fewer items than the page size, and stop triggering fetches.

- **[critical] 快速 toggle favorite 的竞态条件** — `FavIconController` uses a `ValueNotifier<bool>` with async `DbHelper.putFavorite()` persistence. If the user taps the heart rapidly (on→off→on), multiple async writes are in-flight simultaneously. The final UI state may not match the database state (last write wins, but write order is undefined). / 当前处理: 无 / 建议: Debounce the toggle input; queue writes and ignore new toggles while a write is pending; or use optimistic UI with a rollback on failure.

- **[high] Infinite scroll 内容不足一屏时无限触发** — When the grid has fewer items than the viewport height, `position.maxScrollExtent` equals `0` (or the current extent if no scroll is possible). The condition `position.pixels == position.maxScrollExtent` evaluates true immediately, causing continuous `fetchMore()` calls in a tight loop until the API returns empty. / 当前处理: 无 / 建议: Add a guard to prevent fetching when already fetching, and check that `maxScrollExtent > 0` before triggering.

- **[high] 幻灯片模式 + 视频播放冲突** — The slideshow uses `Timer.periodic` to auto-advance pages. When a page contains a video (auto-play + looping), the slideshow timer does not pause. The video could be interrupted mid-play by the next auto-advance. Users may never see a full video in slideshow mode. / 当前处理: 无 / 建议: Detect video content in slideshow mode; either pause the timer while a video plays, or skip video pages in slideshow, or add a "video detected" indicator.

- **[high] 幻灯片快速切换播放/暂停** — Rapid toggling of the slideshow play/pause button could create multiple concurrent `Timer.periodic` instances (if the timer isn't properly disposed before starting a new one). This would cause the gallery to advance at double or triple speed. / 当前处理: 无 / 建议: Cancel (`cancel()`) the existing timer in the "pause" branch and ensure `Timer.periodic` is always assigned to null before creating a new one.

- **[high] Gallery 翻页时缩放状态未重置** — `PhotoViewGallery` supports pinch-to-zoom (1.0x-4.0x). When the user swipes to the next page, the zoom level is likely retained from the previous image. A zoomed-in image followed by a swipe could confuse the user (next image appears zoomed in unexpectedly). / 当前处理: 无 / 建议: Reset zoom to 1.0x on page change, or animate a smooth zoom-out on swipe.

- **[medium] 收藏操作失败时 toast 误报成功** — The toast "Faved" / "Unfaved" fires immediately after the toggle action, before the async `DbHelper.putFavorite()` completes. If the database write fails (disk full, corruption), the UI shows a false confirmation. / 当前处理: 无 / 建议: Move toast to the completion callback of the async write; show "Failed to save favorite" on error.

- **[medium] Infinite scroll 滚动过快触发多次 fetch** — There is no debouncing on the `ScrollController` listener. A user rapidly flicking to the bottom of the list could trigger `fetchMore()` multiple times before the first fetch resolves, causing duplicate page requests and inconsistent data ordering. / 当前处理: 无 / 建议: Add an `_isFetching` guard that rejects new fetches while one is in progress.

- **[medium] 视频播放错误无恢复路径** — When the video player encounters an error (corrupted file, network timeout), it shows `Icons.error_outline` (size 50) with no retry mechanism. The user is stuck on a broken video page with no way to reload. / 当前处理: 仅显示错误图标 / 建议: Add a "Tap to retry" overlay on the error icon that reinitializes the video player.

- **[low] 搜索历史过多时的性能问题** — `InputHistoryTextField` persists history to SharedPreferences. No maximum history size is mentioned. Over months of use, the history list could grow to hundreds of entries, slowing down SharedPreferences serialization and the search page on every launch. / 当前处理: 无 / 建议: Limit history to 50 entries with a FIFO eviction policy; show "Clear history" action.

### 数据一致性 (6 findings)

- **[critical] 切换 booru 时正在进行的 API 请求产生脏数据** — When the user switches booru in the ChangeBooruDialog, any in-flight API requests for the previous booru (trending page fetches, image loading) continue to resolve and may populate the UI with images from the wrong booru. The `SearchInterface` model has no cancellation mechanism. / 当前处理: 无 / 建议: Cancel all pending API requests on booru switch via a cancellation token pattern; clear the current image grid before loading new data.

- **[high] 收藏状态跨页面不一致** — If the user opens GalleryView from HomePage, favorites an image (DB write succeeds), then pops back and navigates to FavouritePage, the data should be consistent. However, if FavouritePage caches its result set or the SQLite query doesn't refresh on `initState`, the newly favorited image may not appear. / 当前处理: 依赖 FavouritePage 的初始化时机 / 建议: Reload favorites data in `didChangeDependencies` or use a Provider stream that reactively updates when the DB changes.

- **[high] 滑动幻灯片到结尾时重复包装** — The slideshow wraps from the last image back to the first. If the gallery has only 1 image, the wrap is a no-op (the timer fires but the page doesn't change). This creates a pointless periodic timer that drains battery and does nothing visible. More critically, if the index update logic doesn't guard against 0-length lists, it could crash. / 当前处理: 文件提到 "wraps to first image at end" / 建议: Stop the slideshow timer when gallery has 1 or 0 images; show "End of gallery" indicator.

- **[high] 缓存图片与远程版本不一致** — `CachedNetworkImage` relies on HTTP cache headers for invalidation. If the Derpibooru CDN does not set `Cache-Control: no-cache` or appropriate `ETag` headers for updated images (e.g., a replaced/updated upload), stale versions persist indefinitely in the device cache. The user never sees the updated image unless they manually clear the cache. / 当前处理: 依赖 HTTP 缓存头 / 建议: Add a periodic cache staleness check (e.g., 24-hour TTL for images, regardless of HTTP headers); offer "Refresh" on GalleryView.

- **[medium] 下载未完成时退出页面** — The download action is likely an async file write. If the user starts a download and immediately navigates away or closes the app, the download operation may be cancelled by Flutter's async task lifecycle. No download manager or persistent download queue is documented. / 当前处理: 无 / 建议: Use a download manager that persists across page navigation; show notification for in-progress downloads.

- **[medium] 同时在 GalleryView 和 FavouritePage 操作收藏** — Scenario: User opens FavouritePage (loads favorites from DB), then taps a thumbnail → GalleryView, then unfavorites the image. When pressing back to FavouritePage, the removed image still appears in the grid because the FavouritePage's data snapshot was taken at navigation time and never refreshed. / 当前处理: 无 / 建议: Reload favorites on page visibility change or use a reactive data source (StreamBuilder / Provider) that emits changes.

### 多 surface / 跨页面状态 (6 findings)

- **[critical] 在 Drawer 中切换 booru 时 Trending 数据更新时序** — The trending grid is populated by `TrendingScroll` / `TrendingModel`. When the booru changes via the drawer, the trending model should reload for the new booru. However, if the model does not reset its page counter and clear existing items, the grid shows a mix of old-booru and new-booru images (new pages appended to old data). / 当前处理: 无 / 建议: On booru change, reset the trending model (clear items, reset page index, cancel in-flight requests, fetch first page of new booru).

- **[high] 切换 booru 后 FavouritePage 显示旧 booru 收藏** — The FavouritePage AppBar shows "Favourites: {booru}". If favorites are stored globally (not per-booru), the label is misleading — it should show all favorites regardless of booru. If stored per-booru, switching booru and then opening FavouritePage from an old FAB (if the widget doesn't refresh) might show the wrong collection. / 当前处理: 依赖实现细节 / 建议: Document the favorite storage scope (global vs per-booru) and ensure the UI label matches; refresh on every navigation.

- **[high] 改变搜索设置时不刷新现有 ResultPage** — Search settings (sort direction, sort field, filter) are changed via the HomePage drawer's ChangeParamDialog. If the user has a ResultPage active in the navigation stack (pushed earlier), changing these settings has no effect on the already-loaded results. The user must re-search to see changes. This is an implicit UX expectation mismatch. / 当前处理: 无 / 建议: Provide a visual hint that "Settings apply to next search"; or allow ResultPage to refresh with new params when it regains focus.

- **[medium] 单列/双列切换时 GalleryView 不受影响** — Toggling single/dual column mode in the drawer only affects the grid. If GalleryView is currently open and the user background-navigates to change the setting, the grid behavior changes on return but the transition is unexpected (no visual hint that grid layout changed). / 当前处理: 无（预期行为与网格相关） / 建议: Ensure the grid rebuilds with the new layout when the page regains focus (it likely does via Consumer widget, but should be verified).

- **[medium] 暗黑模式切换时 toast 样式不匹配** — Toast messages shown before/after a dark mode toggle may render with the old theme's background color. `fluttertoast` uses the system default toast style, which may not respect the app's dark mode toggle until the next toast creation. / 当前处理: 无 / 建议: If fluttertoast supports text/background color customization, set them to match the current theme at toast time.

- **[low] 多个 booru 间的搜索历史混合** — `InputHistoryTextField` likely stores search history globally, not per-booru. If the user switches between booru hosts with different tag systems and search APIs, one booru's history entries may not be valid on another booru. Tapping a stale history entry could produce API errors. / 当前处理: 无 / 建议: Scope search history by booru, or add a visual hint showing which booru a history entry was used on.

### 暗黑模式过渡 (6 findings)

- **[high] 标签颜色在暗色背景下对比度不足** — Tag category foreground colors are hardcoded and not theme-aware. In dark mode (background `Colors.grey[850]` ~ #303030), several foreground colors fail WCAG AA contrast (4.5:1 for normal text):
  - `body` category: #4E4E4E on ~#303030 = ~1.9:1 (essentially invisible)
  - `general`: #6F8F0E on ~#303030 = ~3.3:1
  - `official`: #998E1A on ~#303030 = ~3.5:1
  - `spoiler`: #C24523 on ~#303030 = ~4.2:1 (borderline)
  / 当前处理: 硬编码颜色不受主题影响 / 建议: Define separate dark-mode foreground colors for each tag category with verified contrast ratios against grey[850]. Alternatively, add a subtle background dim or outline to tag chips in dark mode.

- **[high] GalleryToolBar 图标在浅色图片上不可见** — All 4 toolbar icons (favorite, download, share, info) use `Colors.white` and the toolbar has no background or shadow. When the current image has a white or light area at the bottom (where the toolbar overlays), the icons become invisible or nearly invisible. / 当前处理: 固定白色无背景 / 建议: Add a translucent dark background (e.g., `Colors.black38`) behind the toolbar row, or add a drop shadow to each icon, or dynamically detect image luminance for contrast.

- **[medium] 暗黑模式切换时动画缺失** — The theme transition is described as "instant" (no animation). Flutter supports `ThemeData` with `animationDuration` for smooth transitions. The instant flip is jarring, especially for users with light sensitivity. / 当前处理: 无 / 建议: Use `AnimatedTheme` or configure `ThemeData.pageTransitionsTheme` to cross-fade between themes over 300-500ms.

- **[medium] Drawer 底部暗黑模式开关在暗模式下难以发现** — The dark mode Switch is in a bottom Container on `Colors.grey[850]` background. In dark mode, the switch track is already dark and may blend into the background. The switch's `MaterialTapTargetSize.shrinkWrap` reduces the tappable area, making it harder to find by touch. / 当前处理: shrinkWrap 尺寸 + 暗色背景 / 建议: Ensure the switch container has a slightly lighter background (e.g., grey[700]) to create contrast; increase tap target size.

- **[low] Semantic 色彩在暗黑模式下未调整** — DetailSheet stats use `Colors.green` (upvote), `Colors.red` (downvote), `Colors.yellow[800]` (faves), `Colors.purple[200]` (comments). These have sufficient contrast in light mode but `Colors.purple[200]` (#CE93D8) on grey[850] (#303030) has ~4.8:1 — adequate but the semantic meaning (comments) does not carry the same visual weight in dark mode. / 当前处理: 无 / 建议: Optionally bump saturation of semantic colors in dark mode to maintain visual hierarchy parity with light mode.

- **[low] Drawer header 图片在暗黑模式下无适配** — The drawer header uses a hardcoded CachedNetworkImage with `BoxFit.cover`. This image was likely selected for light mode aesthetics. In dark mode, the same image may look different (brightness, contrast) and may not match the dark theme aesthetic. / 当前处理: 无 / 建议: Consider using a different drawer header image or overlay a dark gradient for dark mode.

### 国际化边缘情况 (5 findings)

- **[high] Drawer 项目硬编码中文 — 英文模式下显示中文** — The document explicitly states: "Clear Cache, About, Single Column, Dark Mode, Slideshow Interval have hardcoded Chinese strings in `home_page.dart`." When the app language is set to English, these drawer items display in Chinese. This is a visible i18n bug that affects half of the drawer items. / 当前处理: 文档已记录此问题 / 建议: Extract all hardcoded Chinese strings to `.arb` localization files; add English translations.

- **[medium] 日期格式本地化缺失** — The DetailSheet shows dates in `yyyy-MM-dd HH:mm` format regardless of locale. Chinese users would typically expect `yyyy-MM-dd HH:mm` (coincidentally matches), but other locales may expect different formats (e.g., `dd/MM/yyyy` or `MM/dd/yyyy`). / 当前处理: 硬编码格式 / 建议: Use `Intl.date()` with locale-aware formatting, or at minimum use `DateFormat.yMd()` for region-neutral display.

- **[medium] RTL 语言兼容性未验证** — If RTL language support (Arabic, Hebrew, Persian) is added in the future, several documented layouts would likely break:
  - Gallery toolbar `Row` with `MainAxisAlignment.spaceEvenly` — RTL should reverse the order
  - Drawer `ListTile` items — leading icon and title order may reverse
  - DetailSheet stats `Row` — order of upvote/downvote/faves/comments may need RTL-aware ordering
  - FAB column positioning (bottom-right in LTR, bottom-left in RTL)
  / 当前处理: 文档注明只支持 EN 和 ZH / 建议: Use `Directionality` widget and Flutter's RTL-aware widgets (`Row` → `Row.rtl` isn't a thing, but use `MainAxisAlignment.start` with `TextDirection`). Verify all hardcoded `EdgeInsets.only(left: / right:)` values.

- **[medium] 数字格式化本地化缺失** — Stat counts (upvotes: 12345, etc.) are displayed without locale-aware separators. In English, `12,345` is expected; in Chinese, `12,345` or `12345`. The formatting is unspecified, presumably raw `toString()` on an int. / 当前处理: 无 / 建议: Use `NumberFormat.compact()` for large numbers (10k+) or `NumberFormat.decimalPattern()` for locale-aware digit grouping.

- **[low] 翻译覆盖率文档与实际不符** — The Foundation section says "English + Simplified Chinese via `flutter_localizations`", but document itself reveals hardcoded Chinese strings bypassing the localization system. The actual bilingual coverage is incomplete and the gap is undocumented in terms of exact missing keys. / 当前处理: 文档提及但未量化缺口 / 建议: Create a comprehensive localization coverage map showing which strings are in `.arb` and which are hardcoded; prioritize the drawer items.

### 性能边界 (5 findings)

- **[high] 极大量图片滚动时的内存压力** — `CachedNetworkImage` caches images in memory. With thousands of images loaded during extended browsing, the memory cache can grow to hundreds of megabytes on low-end Android devices, triggering GC pauses or OOM crashes. No explicit cache size limit is documented for `ImageCacheManager`. / 当前处理: 依赖 cached_network_image 默认缓存 / 建议: Configure `CachedNetworkImage` with a maximum cache size (e.g., 50 MB) and maximum object count (e.g., 100 images); monitor via `ImageCache().currentSizeBytes`.

- **[high] 视频 + 幻灯片 + 图片预加载同时发生的内存压力** — In GalleryView, slideshow auto-advance triggers preloading of the next image via `PageView`'s default preload (1 page on each side). If the next page is a video (Chewie controller), the video begins buffering in the background. With rapid slideshow intervals (1-3 seconds), multiple video buffers could accumulate simultaneously, overwhelming device memory. / 当前处理: PageView 默认预加载行为 / 建议: Disable `PageView` preload during slideshow mode; release video controllers of off-screen pages; increase preload distance only for images.

- **[high] Infinite scroll 数据累积无上限** — The trending, search, and favorites scroll controllers keep appending fetched items to the model list without any upper bound. Browsing for extended periods (e.g., 30+ minutes) could accumulate thousands of entries in memory. This affects not just image cache but also the SliverGrid's element count, metadata storage, and scroll offset tracking. / 当前处理: 无 / 建议: Implement a virtual scrolling approach or cap the in-memory item count (e.g., keep last 200 items, drop older ones from the model); add "jump to top" FAB for long lists.

- **[medium] Toast 队列堆积** — `fluttertoast` does not have a documented queuing mechanism. If the user rapidly performs actions (e.g., tapping multiple favorite toggles quickly), toasts may overlap, not appear, or appear out of order. The toast messages assume one-at-a-time action patterns. / 当前处理: 无 / 建议: Rate-limit toast display (e.g., show only the latest pending toast, discard intermediate ones) or switch to `SnackBar` in a ScaffoldMessenger queue.

- **[medium] Hero 动画配合大图片可能卡顿** — The `Hero(tag: imageId)` transition animates the thumbnail from grid position to fullscreen. With very large images (4K+ resolution thumbnails), the animation may jank on mid-range Android devices because the `CachedNetworkImage` in the Hero is rendering a high-resolution decode in both start and end states simultaneously during the transition. / 当前处理: 无 / 建议: Use a smaller resolution for the Hero flight (e.g., force the Hero to use the pre-decoded cache thumbnail rather than the full image), or disable the Hero transition for very large images.

## Summary

- **Critical: 4**
  - (1) Empty/invalid search submission with no validation guard
  - (2) Infinite scroll with no termination sentinel (endless API calls)
  - (3) Booru switch with in-flight requests causing cross-booru data pollution
  - (4) Rapid favorite toggle race condition (UI/DB desync)

- **High: 13**
  - Empty states (search results, favorites) with no messaging
  - No offline detection at any surface
  - Tag chip contrast failure in dark mode (some categories invisible)
  - Gallery toolbar icons invisible on light image backgrounds
  - Slideshow + video playback conflict
  - Multiple concurrent Timer instances from rapid slideshow toggle
  - Zoom state not reset on gallery page change
  - Infinite scroll loop when content < viewport height
  - Hardcoded Chinese in drawer items (broken i18n)
  - Cross-booru data mixing on booru switch
  - Cached image staleness (no invalidation strategy)
  - Video error with no retry path
  - Memory pressure from unbounded image accumulation + video preload

- **Medium: 11**
  - Storage permission not checked before download/share
  - Date/number formatting not locale-aware
  - RTL layout compatibility unverified
  - Stale FavouritePage snapshot after unfav in GalleryView
  - Search history not scoped per booru
  - Toast fires before async operation confirms
  - Repeated download clicks not debounced
  - Slideshow on 1-image gallery runs pointless timer
  - Hero animation jank with large images
  - Dark mode transition has no animation
  - Rapid fetchMore on flick-scroll

- **Low: 4**
  - Tag text overflow in chip
  - Unbounded search history growth
  - Drawer header image not adapted for dark mode
  - Semantic color parity not maintained in dark mode

**File:** `e:\Proj\ASproject\derpiviewer\_bmad-output\planning-artifacts\ux-designs\ux-derpiviewer-2026-06-04\review-edge-case-hunter.md`
