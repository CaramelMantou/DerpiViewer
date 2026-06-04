# Derpiviewer - Architecture Document

**Date:** 2026-06-04
**Architecture Pattern:** Provider-based MVVM (Model-View-ViewModel)
**Language:** Dart 3.8.1
**Framework:** Flutter 3.32.7

## Executive Summary

Derpiviewer is a Flutter-based Android application for browsing image boards (boorus) powered by the Philomena software. The app follows a Provider-based MVVM architecture with four `ChangeNotifier` models managing state, direct API calls via a singleton HTTP client, and local SQLite storage for favorites. The architecture is functional but exhibits high coupling between layers due to pervasive use of singletons, static methods, and the absence of a repository/service abstraction layer.

## Architecture Pattern

```
┌──────────────────────────────────────────────────────────────────┐
│                        UI LAYER                                   │
│  ┌──────────┐  ┌───────────┐  ┌──────────┐  ┌──────────────┐   │
│  │ HomePage │  │SearchPage │  │FavPage   │  │ GalleryView  │   │
│  │  Drawer  │  │ResultPage │  │          │  │   ToolBar    │   │
│  └────┬─────┘  └─────┬─────┘  └────┬─────┘  └──────┬───────┘   │
│       │              │             │               │            │
│       └──────────────┴──────┬──────┴───────────────┘            │
│                             │                                     │
│                    Consumer<T> / Provider.of<T>                   │
├─────────────────────────────┼────────────────────────────────────┤
│                      STATE LAYER                                  │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐  ┌──────────┐   │
│  │PrefModel │  │SearchModel│  │TrendingModel │  │ FavModel  │   │
│  │ (root)   │◄─┤           │◄─┤(extends      │  │           │   │
│  │          │  │           │  │ SearchModel) │  │           │   │
│  └────┬─────┘  └─────┬─────┘  └──────┬───────┘  └─────┬─────┘   │
│       │              │               │                │          │
│       │    SearchInterface (abstract contract)         │          │
│       │              │               │                │          │
├───────┼──────────────┼───────────────┼────────────────┼──────────┤
│       │         DATA LAYER (tightly coupled)           │          │
│  ┌────┴──────────────┴───────────────┴────────────────┴────┐    │
│  │              BasePhilomenaClient (singleton)              │    │
│  │              DioClient (singleton)                        │    │
│  │              DbHelper (all static methods)                │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### UI Layer (`lib/pages/`, `lib/widgets/`)
- Renders Flutter widgets in response to state changes
- Consumes models via `Consumer<T>` and `Provider.of<T>()`
- Triggers actions: `fetchMore()`, `newSearch()`, `toggleDarkMode()`, etc.
- Navigation via imperative `Navigator.push()`

### State Layer (`lib/models/`)
- Extends `ChangeNotifier` to notify the UI of state changes
- Contains business logic: pagination, data fetching, preference management
- Directly calls data layer (no intermediary)
- `PrefModel` serves as the root provider; other models depend on it via `ChangeNotifierProxyProvider`

### Data Layer (`lib/api/`, `lib/helpers/`)
- `BasePhilomenaClient`: Singleton wrapping Philomena REST API calls
- `DioClient`: Singleton Dio HTTP instance
- `DbHelper`: Static methods for SQLite CRUD operations
- `ImageResponse`: Dual-purpose DTO for both API responses and DB rows
- No repository abstraction; models call clients directly

## Data Flow

### Search Flow
```
1. User types query → SearchPage
2. SearchModel.newSearch(query)
3. → BasePhilomenaClient.fetchImages(booru, query, params)
4. → DioClient.getUri() → Philomena API
5. ← List<ImageResponse>
6. SearchModel.results = [...], notifyListeners()
7. → Consumer<SearchModel> rebuilds ImageGrid
```

### Favorites Flow
```
1. User taps heart icon → GalleryToolBar
2. DbHelper.getFavorite(booru, id) → check current state
3. DbHelper.putFavorite(booru, image, !current) → toggle
4. FavModel.changeFav() → re-fetch from DB
5. notifyListeners() → UI rebuild
```

### Preferences Flow
```
1. User changes setting → Dialog → PrefModel.updateParams(...)
2. PrefModel.notifyListeners()
3. PrefModel.savePref() → SharedPreferences (async)
4. ProxyProvider detects PrefModel change → resets SearchModel/TrendingModel/FavModel
```

## Key Design Decisions

### 1. Provider over Riverpod/BLoC
**Decision:** Provider package with ChangeNotifier.
**Rationale:** Provider is the simplest state management solution recommended by Flutter. For this app's complexity level (4 models, ~20 files), it's adequate. Riverpod or BLoC would be over-engineered for the current scope.

### 2. Singleton API Client
**Decision:** `BasePhilomenaClient` as a singleton factory.
**Impact:** Simplifies access — any model can call `BasePhilomenaClient()` and get the same instance. But makes testing impossible and prevents configuration per booru.

### 3. Static DB Helper
**Decision:** All `DbHelper` methods are static.
**Impact:** No instantiation needed, but SQLite operations cannot be mocked or swapped. The DB is initialized once at app start and never explicitly closed until the app exits.

### 4. No Repository Layer
**Decision:** Models call API/DB directly.
**Impact:** Simpler code (fewer files), but data source changes require model changes. Caching strategies, offline support, or data source swapping would require significant refactoring.

### 5. ImageResponse as Universal DTO
**Decision:** Single class serves as API response DTO, DB entity, and UI display object.
**Impact:** Fewer classes and no mapping code. But tightly couples API contract to DB schema and UI expectations. The `fromJson` factory includes booru-specific URL correction logic that should live elsewhere.

## Dependency Map

```
main.dart
  ├── PrefModel ← SharedPreferences
  ├── TrendingModel extends SearchModel ← BasePhilomenaClient
  ├── SearchModel ← BasePhilomenaClient
  ├── FavModel implements SearchInterface ← DbHelper
  └── DVApp ← PrefModel (theme)

enums.dart ← Imported by ALL modules
  - Booru, SortField, SortDirection, Size, ContentFormat, TagCategory
  - ConstStrings: API hosts, paths, filter maps, UI colors, l10n helpers

Cross-cutting concerns (no centralized module):
  - DownloadHelper (static) → flutter_downloader + share_plus
  - Clipboard + Toast (free functions) → fluttertoast
  - ImageCacheManager / VideoCacheManager → flutter_cache_manager
```

## Testing Strategy

**Current state:** No active tests exist. The default `test/widget_test.dart` from the Flutter template is present but likely outdated.

**What would be needed for testability:**
1. **Dependency injection** — Replace singletons with injectable interfaces
2. **Repository interfaces** — Abstract `ImageRepository`, `FavoritesRepository`
3. **Model isolation** — Separate business logic from `ChangeNotifier` lifecycle
4. **Mock HTTP client** — Dio interceptors or a mock Dio instance
5. **In-memory DB for tests** — `sqflite_common_ffi` for desktop testing

## Security Considerations

- **API key stored in plaintext** via `SharedPreferences` — not encrypted at rest
- **No HTTPS pinning** — Dio uses default TLS verification only
- **SQLite DB in external storage** — `getExternalStorageDirectory()` makes the database potentially accessible to other apps with storage permissions
- **No input sanitization** on search queries before sending to API

## Known Architecture Issues (Refactoring Targets)

| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| High | God file mixing config, UI, and l10n | `lib/enums.dart` | Split into `config/`, `theme/` modules |
| High | Singletons prevent testing | `clients.dart`, `connect.dart` | DI via `get_it` or interfaces |
| High | Static DB helper | `db.dart` | Repository pattern with injectable `FavoritesRepository` |
| Medium | No service/repository layer | all models | Add `ImageRepository`, `FavoritesRepository` interfaces |
| Medium | SearchInterface in wrong file | `search_model.dart:157` | Move to `lib/core/domain/` or `lib/models/` dedicated file |
| Medium | ImageResponse dual role | `do.dart` | Separate `ImageDto` (API) from `ImageEntity` (domain) |
| Low | home_page.dart too large | `home_page.dart` | Split into `HomePage`, `TrendingScroll`, `HomeDrawer` files |
| Low | BuildContext in ConstStrings | `enums.dart:88` | Move l10n lookup to UI layer, remove ctx dependency from config |

---

_Generated using BMAD Method `document-project` workflow_
