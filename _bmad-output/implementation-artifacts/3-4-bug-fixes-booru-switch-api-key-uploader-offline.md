---
baseline_commit: f355fe0
---

# Story 3.4: Bug Fixes — Booru Switch Cancel, API Key Validation, Uploader Tap, Offline Banner

Status: done

## Story

As a user,
I want switching boorus to not mix data, invalid API keys to show clear errors, uploader names to be tappable, and offline mode to be clearly indicated,
so that the app handles edge cases gracefully and never shows wrong or confusing data.

## Acceptance Criteria

1. **Given** the user switches boorus (e.g., from trixie to derpi)
   **When** `PrefModel.changeHost(newBooru)` fires
   **Then** all in-flight API requests for the previous booru are cancelled via a `CancelToken`
   **And** the trending/search grid clears before showing new booru data
   **And** a loading state is shown while the new booru's data loads
   **And** no images from the old booru appear in the new booru's grid

2. **Given** a user has entered an invalid or expired API key
   **When** any API request returns HTTP 403
   **Then** the error mapper produces `FailureType.api` with message "API key invalid or expired"
   **And** the UI shows a `SnackBar`: "API key rejected. Update it in Settings." with an action button that opens `ChangeKeyDialog`

3. **Given** the user views a DetailSheet
   **When** they tap the uploader name
   **Then** it navigates to SearchPage with `uploader:{name}` pre-filled as the initial query
   **And** if uploader is empty/"Background Pony", the name remains non-tappable static text

4. **Given** the device loses network connectivity
   **When** the app detects offline state via `connectivity_plus`
   **Then** a `MaterialBanner` appears at the top of HomePage: "You're offline — showing cached content."
   **And** the search FAB remains visible but shows a disabled visual (greyed out, not tappable)
   **And** the offline banner auto-dismisses when connectivity returns

5. **Given** `flutter analyze` runs
   **Then** zero errors
   **And** all existing tests continue to pass with zero regressions

## Tasks / Subtasks

- [x] Task 1: Add CancelToken to cancel in-flight requests on booru switch (AC: 1)
  - [x] Add `connectivity_plus` to pubspec.yaml
  - [x] Add optional `CancelToken? cancelToken` parameter to `ImageRepository` interface methods
  - [x] Pass cancelToken through `ImageRepositoryImpl` to Dio calls
  - [x] Hold a `CancelToken?` in `TrendingProvider` — cancel on booru switch, recreate for new requests
  - [x] Clear trending grid (`images = []`) when refreshing after booru switch
  - [x] Verify: rapid booru switches don't cause mixed data

- [x] Task 2: Enhance 403 API key error handling (AC: 2)
  - [x] Update `error_mapper.dart`: 403 message → "API key invalid or expired"
  - [x] In `ResultPage` and `TrendingScroll`: detect `FailureType.api` and show SnackBar with action to open ChangeKeyDialog
  - [x] SnackBar: "API key rejected. Update it in Settings." + action button → opens `ChangeKeyDialog`

- [x] Task 3: Make uploader name tappable (AC: 3)
  - [x] In `lib/widgets/detail.dart`: wrap uploader name Text with GestureDetector
  - [x] On tap: `Navigator.push` to SearchPage with `initQuery: 'uploader:$name'`
  - [x] When uploader is empty ("Background Pony"), keep static non-tappable text
  - [x] Add visual affordance: underline or blue color (already blue per UX spec)

- [x] Task 4: Add offline connectivity banner (AC: 4)
  - [x] Add `connectivity_plus` to pubspec.yaml dependencies
  - [x] Create `lib/ui/providers/connectivity_provider.dart` — watches connectivity stream, exposes `isOnline`
  - [x] Register in DI container + wire in main.dart via `ChangeNotifierProvider`
  - [x] In HomePage body: wrap with provider, show `MaterialBanner` when offline
  - [x] Disable search FAB when offline (grey color + no-op onPressed)

- [x] Task 5: Run full validation (AC: 5)
  - [x] `flutter analyze` — zero errors
  - [x] `flutter test` — all 104 tests pass with zero regressions

## Dev Notes

### Current State Analysis

#### Booru Switch Flow (current, broken)

```
PrefModel.changeHost(b) 
  → booru = b; updateParams(fn, fid)
  → TrendingProvider.onPrefsChanged(prefs)
    → fetchMore(refresh: true)
      → repository.getFeaturedImage(booru, ...)  // NO cancel token
      → repository.searchImages(booru, ...)       // NO cancel token
```

**Problem:** If the user switches from trixie to derpi quickly, the trixie API response could arrive AFTER the derpi response, populating the grid with wrong-booru images. No in-flight request cancellation exists.

#### Solution: CancelToken Pattern

```dart
// lib/core/domain/repositories/image_repository.dart — add parameter
abstract class ImageRepository {
  Future<Result<ImageEntity>> getImage(
    Booru booru, int id, {String? apiKey, CancelToken? cancelToken}
  );
  Future<Result<List<ImageEntity>>> searchImages({
    required Booru booru, required String query, required SearchParams params,
    String? apiKey, CancelToken? cancelToken,
  });
  Future<Result<ImageEntity>> getFeaturedImage(
    Booru booru, {String? apiKey, CancelToken? cancelToken}
  );
}

// lib/core/data/repositories/image_repository_impl.dart — pass to Dio
final response = await strategy.dio.getUri(uri, cancelToken: cancelToken);

// lib/ui/providers/trending_provider.dart — manage cancel token
CancelToken? _cancelToken;

@override
void onPrefsChanged(PrefModel prefs) {
  // Cancel all in-flight requests from previous booru
  _cancelToken?.cancel('Booru switched');
  _cancelToken = CancelToken();
  // Clear old data immediately
  images = [];
  hasMore = true;
  currentPage = 1;
  _featuredState = const LoadingState();
  state = const LoadingState();
  notifyListeners();
  // Fetch new booru data
  fetchMore(refresh: true);
}

Future<void> fetchMore({bool refresh = false}) async {
  await fetchLock.synchronized(() async {
    // ... existing guards ...
    
    if (refresh && _cancelToken == null) {
      _cancelToken = CancelToken();
    }
    
    final featured = await repository.getFeaturedImage(
      prefProvider.booru,
      apiKey: prefProvider.key,
      cancelToken: _cancelToken,
    );
    // ... same for searchImages call ...
    
  }, onError: (e) {
    if (e is DioError && e.type == DioErrorType.cancel) {
      // Request was cancelled — silently ignore (not an error)
      return;
    }
  });
}
```

**Catch cancellation gracefully:** Wrap the Dio calls in try-catch that silently swallows `DioErrorType.cancel` — a cancelled request is expected behavior, not an error to display.

#### CancelToken in TrendingProvider

The `SearchProvider` (parent of `TrendingProvider`) also has `fetchMore`. The tracking of CancelToken should be in `TrendingProvider` since it's the one that handles booru-switch-initiated refreshes. SearchProvider's fetchMore is for user-initiated searches and doesn't need booru-switch cancellation.

### API Key 403 Error Enhancement (Task 2)

**error_mapper.dart change (line 48-53):**
```dart
// Before:
if (statusCode == 403 || statusCode == 401) {
  return Failure(
    'API access denied ($statusCode)',
    FailureType.api,
    error: error,
    stackTrace: error.stackTrace,
  );
}

// After:
if (statusCode == 403 || statusCode == 401) {
  final message = statusCode == 403
      ? 'API key invalid or expired'
      : 'Authentication required ($statusCode)';
  return Failure(
    message,
    FailureType.api,
    error: error,
    stackTrace: error.stackTrace,
  );
}
```

**UI: Show SnackBar for API failures (in ResultPage / TrendingScroll / SearchProvider):**

When ViewState is `FailureState(type: FailureType.api)`:
```dart
// After render, check if this is an API key error
void _showApiKeySnackbar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Text('API key rejected. Update it in Settings.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ChangeKeyDialog(),
          );
        },
      ),
      duration: const Duration(seconds: 6),
    ),
  );
}
```

This should be triggered from the page that receives the error (ResultPage has access to SearchProvider; TrendingScroll can check TrendingProvider's state).

### Uploader Name Tappable (Task 3)

**detail.dart — replace lines 54-59:**

```dart
// After:
Align(
  alignment: Alignment.centerLeft,
  child: _image.uploader.isEmpty
      ? const Text(
          'Background Pony',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 40, 135, 203)),
        )
      : GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(initQuery: 'uploader:${_image.uploader}'),
              ),
            );
          },
          child: Text(
            _image.uploader,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 40, 135, 203),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
),
```

The underline `decoration` provides a clear visual affordance that the name is tappable.

### Offline Banner (Task 4)

#### New file: `lib/ui/providers/connectivity_provider.dart`

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    _connectivity.checkConnectivity().then(_updateStatus);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

#### Register in main.dart:

```dart
ChangeNotifierProvider<ConnectivityProvider>(
  create: (_) => ConnectivityProvider(),
),
```

#### Add to pubspec.yaml:

```yaml
dependencies:
  connectivity_plus: ^6.0.0
```

#### HomePage offline banner:

```dart
// In home_page.dart, wrap body with:
body: Consumer<ConnectivityProvider>(
  builder: (context, connectivity, child) {
    return Column(
      children: [
        if (!connectivity.isOnline)
          MaterialBanner(
            content: const Text("You're offline — showing cached content."),
            leading: const Icon(Icons.wifi_off),
            backgroundColor: Colors.grey[800],
            actions: [],
          ),
        Expanded(child: const TrendingScroll()),
      ],
    );
  },
),
```

#### Disable search FAB when offline:

```dart
FloatingActionButton(
  onPressed: connectivity.isOnline
      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()))
      : null, // null = disabled (greyed out)
  heroTag: "sch-fab",
  child: const Icon(Icons.search),
),
```

The FAB needs `connectivity.isOnline` access. Since the FAB is in the Scaffold body already wrapped with Consumer, lift the Consumer to wrap the entire Scaffold or use a separate Consumer:

```dart
Consumer<ConnectivityProvider>(
  builder: (context, connectivity, child) => Scaffold(
    // ...
    floatingActionButton: Column(
      children: [
        FloatingActionButton(
          heroTag: "fav-fab",
          onPressed: () { /* favorites — always works */ },
          child: const Icon(Icons.favorite),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: "sch-fab",
          onPressed: connectivity.isOnline
              ? () => Navigator.push(...)
              : null,
          child: const Icon(Icons.search),
        ),
      ],
    ),
    body: /* TrendingScroll + optional offline banner */,
  ),
)
```

### Files to Create

| File | Purpose |
|------|---------|
| `lib/ui/providers/connectivity_provider.dart` | Connectivity monitoring, exposes `isOnline` |

### Files to Modify

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `connectivity_plus: ^6.0.0` |
| `lib/core/domain/repositories/image_repository.dart` | Add optional `CancelToken? cancelToken` to 3 methods |
| `lib/core/data/repositories/image_repository_impl.dart` | Pass `cancelToken` to Dio calls |
| `lib/ui/providers/trending_provider.dart` | Manage `_cancelToken`, cancel on booru switch, clear old data |
| `lib/core/data/error_mapper.dart` | 403 → "API key invalid or expired" message |
| `lib/widgets/detail.dart` | Make uploader name tappable |
| `lib/pages/home_page.dart` | Add `ConnectivityProvider` consumer, offline banner, disable search FAB |
| `lib/main.dart` | Register `ConnectivityProvider` in MultiProvider |
| `lib/pages/result_page.dart` or relevant files | API key 403 SnackBar handling |

### Preserved Behaviors (MUST NOT BREAK)

- Booru switching via drawer must still update AppBar title and reload data
- API key field must still accept input and save to SharedPreferences
- DetailSheet ID chip, description, stats, and tags remain functional
- Favorites FAB must always work (SQLite local, no network needed)
- Uploader display for anonymous posts ("Background Pony") unchanged
- Slideshow timer, pinch-to-zoom, gallery swipe all preserved
- All existing tests pass

### References

- [Epics: Story 3.4](_bmad-output/planning-artifacts/epics.md#story-34-bug-fixes--booru-switch-cancel-api-key-validation-uploader-tap-offline-banner)
- [UX-DR4: Offline banner](_bmad-output/planning-artifacts/epics.md)
- [UX-DR19: Cancel in-flight requests on booru switch](_bmad-output/planning-artifacts/epics.md)
- [UX-DR20: API key validation](_bmad-output/planning-artifacts/epics.md)
- [UX-DR21: Uploader name tappable](_bmad-output/planning-artifacts/epics.md)
- [Architecture: Error Flow](_bmad-output/planning-artifacts/architecture.md#integration-points) — DioException → error_mapper → Failure → Provider → FailureState → ErrorView
- [connectivity_plus pub.dev](https://pub.dev/packages/connectivity_plus)
- Current source: `lib/core/data/error_mapper.dart` (82 lines)
- Current source: `lib/core/domain/repositories/image_repository.dart`
- Current source: `lib/ui/providers/trending_provider.dart` (162 lines)
- Current source: `lib/widgets/detail.dart` (205 lines)
- Current source: `lib/pages/home_page.dart` (101 lines)

## Dev Agent Record

### Agent Model Used

Claude (BMad create-story workflow)

### Completion Notes List

- Story 3.4 created covering 4 bug fixes: booru switch cancel, API key 403 handling, uploader tap, offline banner
- CancelToken pattern: optional parameter through Repository interface → Dio calls; TrendingProvider holds + cancels on booru switch
- 403 error: enhanced message in error_mapper + SnackBar with action to open ChangeKeyDialog
- Uploader: GestureDetector → SearchPage with `uploader:name` query; non-tappable when empty
- Offline: connectivity_plus → ConnectivityProvider → MaterialBanner in HomePage + disabled search FAB
- 1 file created, 12 files modified, 1 dependency added (connectivity_plus)

### Implementation (2026-06-05)

**Task 1 — CancelToken:**
- Added `CancelToken? cancelToken` to all 3 `ImageRepository` interface methods
- `ImageRepositoryImpl`: passes `cancelToken` to `strategy.dio.getUri(uri, cancelToken: cancelToken)`, rethrows `DioErrorType.cancel`
- `TrendingProvider`: holds `CancelToken? _cancelToken`, cancels on booru switch in `onPrefsChanged`, clears `images`/`hasMore`/`currentPage`, recreates token, calls `fetchMore(refresh: true)`
- `fetchMore`: ensures `_cancelToken ??= CancelToken()`, passes to both repo calls, catches `DioErrorType.cancel` in `on DioError` block and returns silently

**Task 2 — 403 error:**
- `error_mapper.dart`: 403 → "API key invalid or expired", 401 → "Authentication required (401)"
- `ResultPage._ResultScrollState` and `TrendingScroll._TrendingScrollState`: added `_apiSnackbarShown` guard + `_showApiKeySnackbar()` method; triggers on `FailureState(type: FailureType.api)` via `addPostFrameCallback`

**Task 3 — Uploader tap:**
- `detail.dart`: `_image.uploader.isEmpty` branch — static "Background Pony" text; else — `GestureDetector` → `Navigator.push` to `SearchPage(initQuery: 'uploader:$name')` with `TextDecoration.underline`

**Task 4 — Offline banner:**
- `connectivity_provider.dart`: wraps `connectivity_plus`, exposes `isOnline` via `ChangeNotifier`
- `main.dart`: registered as `ChangeNotifierProvider<ConnectivityProvider>()` in `MultiProvider`
- `home_page.dart`: wrapped `Scaffold` in `Consumer<ConnectivityProvider>`, added `MaterialBanner` with wifi_off icon, disabled search FAB via `onPressed: connectivity.isOnline ? ... : null`

**Validation:**
- `flutter analyze`: 0 errors (93 pre-existing info/warnings only)
- `flutter test`: 104/104 pass (updated error_mapper_test 403 assertion)
- All 5 acceptance criteria satisfied

### File List

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `connectivity_plus: ^6.0.0` dependency |
| `lib/core/domain/repositories/image_repository.dart` | Add optional `CancelToken? cancelToken` to `getImage`, `searchImages`, `getFeaturedImage` |
| `lib/core/data/repositories/image_repository_impl.dart` | Pass `cancelToken` to Dio calls; rethrow `DioErrorType.cancel` |
| `lib/core/data/error_mapper.dart` | 403 → "API key invalid or expired"; 401 → "Authentication required (401)" |
| `lib/ui/providers/trending_provider.dart` | Manage `_cancelToken`, cancel on booru switch, clear old data, handle cancel silently |
| `lib/ui/providers/connectivity_provider.dart` | **NEW** — monitors connectivity stream, exposes `isOnline` |
| `lib/pages/home_page.dart` | Wrap with `Consumer<ConnectivityProvider>`, add offline `MaterialBanner`, disable search FAB when offline |
| `lib/main.dart` | Register `ChangeNotifierProvider<ConnectivityProvider>` |
| `lib/pages/result_page.dart` | Detect `FailureType.api` → show API key SnackBar with Settings action |
| `lib/ui/widgets/trending_scroll.dart` | Detect `FailureType.api` → show API key SnackBar with Settings action |
| `lib/widgets/detail.dart` | Make uploader name tappable → `SearchPage(initQuery: 'uploader:$name')`; underline affordance |
| `test/core/data/repositories/error_mapper_test.dart` | Update 403 test assertion: `contains('403')` → `contains('API key invalid')` |

### Change Log

- 2026-06-05: Story 3.4 implemented — CancelToken on booru switch, 403 API key error handling, tappable uploader, offline connectivity banner

### Review Findings

#### decision-needed

(None)

#### patch

- [x] [Review][Patch] CancelToken cancel leaves state stuck in LoadingState — restore currentPage + preserve existing data; new onPrefsChanged fetchMore updates state [lib/ui/providers/trending_provider.dart:149-153]
- [x] [Review][Patch] Uploader name special characters break search query — wrap in double quotes + escape embedded quotes [lib/widgets/detail.dart:69]
- [x] [Review][Patch] ConnectivityProvider has no error handling — added `.catchError()` on `checkConnectivity()` + `onError` on stream listen [lib/ui/providers/connectivity_provider.dart:21-22]
- [x] [Review][Patch] _apiSnackbarShown never resets — reset flag on LoadingState/SuccessState transitions [lib/pages/result_page.dart:39, lib/ui/widgets/trending_scroll.dart:28]
- [x] [Review][Patch] First frame always shows isOnline=true — changed default to `_isOnline = false` [lib/ui/providers/connectivity_provider.dart:13]
- [x] [Review][Patch] MaterialBanner as Column child loses animation — now using `ScaffoldMessenger.showMaterialBanner()` with dismiss button [lib/pages/home_page.dart:82-90]

#### defer

- [x] [Review][Defer] Dio import in domain layer — `package:dio/dio.dart` imported in domain interface for CancelToken; architectural refactoring needed [lib/core/domain/repositories/image_repository.dart:1]
- [x] [Review][Defer] Duplicated API-key snackbar logic — identical `_apiSnackbarShown` + `_showApiKeySnackbar` in ResultPage and TrendingScroll [lib/pages/result_page.dart, lib/ui/widgets/trending_scroll.dart]
- [x] [Review][Defer] ConnectivityProvider async in constructor — `_init()` fires async `checkConnectivity()`; potential timing gap if synchronous on some platforms [lib/ui/providers/connectivity_provider.dart:16-17]
- [x] [Review][Defer] GestureDetector touch target below 48dp — uploader name tap area at ~22dp height; Material minimum is 48dp [lib/widgets/detail.dart:63-78]
- [x] [Review][Defer] SearchProvider lacks CancelToken — user search requests not cancelled on booru switch; by design per dev notes [lib/ui/providers/search_provider.dart:99]
- [x] [Review][Defer] Consumer<ConnectivityProvider> rebuilds entire Scaffold — connectivity change triggers unnecessary full Scaffold rebuild [lib/pages/home_page.dart:74]
