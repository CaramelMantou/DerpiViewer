# Derpiviewer - Development Guide

**Date:** 2026-06-04

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Flutter SDK | 3.32.7+ | Stable channel |
| Dart SDK | 3.8.1+ | Bundled with Flutter |
| Android SDK | minSdk 21 | For APK builds |
| JDK | 11+ | Required by Android toolchain |

## Environment Setup

### 1. Install Flutter

```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"
# Verify
flutter doctor
```

### 2. Clone & Install Dependencies

```bash
git clone https://github.com/CaramelMantou/derpiviewer
cd derpiviewer
flutter pub get
```

### 3. Platform Setup

```bash
# Accept Android licenses
flutter doctor --android-licenses
```

## Common Commands

### Development

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run with specific target
flutter run -d <device_id>
```

### Build

```bash
# Build split APKs (per ABI) — recommended for release
flutter build apk --split-per-abi

# Build single fat APK
flutter build apk

# Build Android App Bundle
flutter build appbundle
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality

```bash
# Run static analysis
flutter analyze

# Auto-fix lint issues
dart fix --apply
```

### Localization

```bash
# Regenerate localization files after editing .arb files
flutter gen-l10n
```

## Project Architecture (Quick Reference)

```
lib/
├── api/         # HTTP client + DTOs
├── models/      # ChangeNotifier state management
├── pages/       # Top-level screens
├── widgets/     # Reusable UI components
├── helpers/     # Infrastructure (DB, cache, download, network)
├── style/       # Themes
├── l10n/        # Localization
├── enums.dart   # Enums + constants
└── main.dart    # Entry point + Provider setup
```

**State Management:** Provider with ChangeNotifier models. `PrefModel` is the root provider; `SearchModel`, `TrendingModel`, and `FavModel` are ProxyProviders that depend on it.

**Navigation:** Imperative Navigator.push with MaterialPageRoute. No named routes or router package.

**Data Flow:**
```
User Action → Page → Model.fetchMore() → API Client / DB Helper → Update State → notifyListeners() → UI Rebuild
```

## Dependency Overview

| Layer | Key Dependencies |
|-------|-----------------|
| HTTP | dio ^4.0.6 |
| State | provider ^6.0.3 |
| Database | sqflite (SQLite) |
| Preferences | shared_preferences ^2.5.3 |
| Images | cached_network_image ^3.2.2, photo_view ^0.14.0 |
| Video | chewie ^1.12.1, video_player ^2.10.0 |
| Downloads | flutter_downloader ^1.12.0 |
| Sharing | share_plus ^11.0.0 |
| i18n | flutter_localizations (SDK), intl |

## Adding a New Feature (Example: New Booru Support)

1. Add entry to `Booru` enum in `lib/enums.dart`
2. Add host/paths to `ConstStrings.boorus`, `searchPaths`, `trendingPaths`
3. Add filters to `ConstStrings.filters`
4. If API version differs from v1, add conditional branch in `BasePhilomenaClient`
5. Test by selecting the new booru from ChangeBooruDialog

## Adding a New Page

1. Create page file in `lib/pages/`
2. If it needs data, consume the appropriate model via `Consumer<T>` or `Provider.of<T>(context)`
3. Navigate to it via `Navigator.push(context, MaterialPageRoute(...))`

## Known Development Pain Points

1. **No hot-reload of model changes** — Changes to model constructors require full app restart due to Provider initialization in main.dart
2. **No mock/test infrastructure** — Singletons (BasePhilomenaClient, DbHelper, DioClient) make unit testing impossible without refactoring
3. **Enums.dart is a change magnet** — Adding any constant, color, or config requires modifying this 255-line file; merge conflicts are likely
4. **No router** — Navigation is entirely imperative; deep linking is not supported
5. **Filter IDs are hardcoded** — Changing a booru's filter IDs requires a code change and app update rather than a remote config

---

_Generated using BMAD Method `document-project` workflow_
