# Derpiviewer - Project Overview

**Date:** 2026-06-04
**Type:** Mobile Application
**Architecture:** Provider-based MVVM

## Executive Summary

Derpiviewer is a Flutter-based Android application for browsing image boards (boorus) powered by the Philomena software. It supports 7 different booru hosts, features search with configurable filters and sorting, infinite-scroll trending and search results, a full-screen photo gallery with slideshow mode, local favorites management via SQLite, download and share capabilities, and supports both English and Chinese (Simplified) localization. The app is a single-developer project with approximately 1100 lines of Dart code across 20 source files.

## Project Classification

- **Repository Type:** Monolith (single Flutter application)
- **Project Type:** Mobile (Flutter/Dart)
- **Primary Language:** Dart
- **Architecture Pattern:** Provider + ChangeNotifier (MVVM-like)
- **Target Platform:** Android (minSdk 21)

## Technology Stack Summary

| Category | Technology | Version |
|----------|-----------|---------|
| Framework | Flutter | 3.32.7 |
| Language | Dart | 3.8.1 |
| State Management | Provider | ^6.0.3 |
| HTTP Client | Dio | ^4.0.6 |
| Database | sqflite (SQLite) | any |
| Preferences | shared_preferences | ^2.5.3 |
| Image Caching | cached_network_image | ^3.2.2 |
| Image Viewer | photo_view | ^0.14.0 |
| Video Player | chewie + video_player | ^1.12.1 / ^2.10.0 |
| Download Manager | flutter_downloader | ^1.12.0 |
| Share | share_plus | ^11.0.0 |
| i18n | flutter_localizations + intl | SDK |

## Key Features

1. **Multi-Booru Support** — Browse 7 Philomena-powered image boards
2. **Trending Feed** — Featured image + infinite-scroll trending grid with configurable filters
3. **Search** — Full-text search with sort direction, sort field, and per-booru filter selection
4. **Gallery Viewer** — Full-screen photo viewer with pinch-to-zoom, swipe navigation, and slideshow mode (1-30s intervals)
5. **Favorites** — Local SQLite-backed favorites with add/remove and paginated viewing
6. **Download & Share** — Download images/videos at configurable sizes; share images or links
7. **Dark Mode** — Toggleable light/dark theme
8. **Dual Language** — English + Simplified Chinese (简体中文) UI
9. **Single/Dual Column** — Toggle between single and dual column grid layout
10. **Cache Management** — Separate image and video cache clearing

## Repository Structure

```
lib/ (20 source files, ~1100 LOC)
├── api/          # HTTP client + DTOs (2 files)
├── models/       # ChangeNotifier state management (4 files)
├── pages/        # Top-level screens (5 files)
├── widgets/      # Reusable UI components (6 files)
├── helpers/      # Infrastructure (5 files + 1 placeholder)
├── style/        # Material themes (1 file)
└── l10n/         # EN + ZH localization (5 files)
```

## Development Overview

### Prerequisites
- Flutter SDK 3.32.7+, Dart 3.8.1+, Android SDK

### Getting Started
```bash
git clone https://github.com/CaramelMantou/derpiviewer
cd derpiviewer
flutter pub get
flutter run
```

### Key Commands
- **Install:** `flutter pub get`
- **Dev:** `flutter run`
- **Build:** `flutter build apk --split-per-abi`
- **Test:** `flutter test`

## Documentation Map

For detailed information, see:

- [index.md](./index.md) — Master documentation index
- [architecture.md](./architecture.md) — Detailed technical architecture with dependency maps
- [source-tree-analysis.md](./source-tree-analysis.md) — Annotated directory structure
- [development-guide.md](./development-guide.md) — Development workflow and common tasks
- [api-contracts.md](./api-contracts.md) — Philomena API endpoints and schemas
- [data-models.md](./data-models.md) — Database schema, entities, and preferences
- [component-inventory.md](./component-inventory.md) — UI component catalog and patterns
- [philomena_api.md](../philomena_api.md) — Philomena API field reference (existing doc)

---

_Generated using BMAD Method `document-project` workflow_
