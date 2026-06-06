---
title: 'Bump version from 1.0.0 to 1.1.0'
type: 'chore'
created: '2026-06-06'
status: 'done'
route: 'one-shot'
---

# Bump version from 1.0.0 to 1.1.0

## Intent

**Problem:** The project version in `pubspec.yaml` is stale at 1.0.0 despite 23 commits (14 feat, 5 fix, 1 refactor, 3 chore) adding substantial backward-compatible new features including dark mode, i18n, accessibility, favorite tags, fullscreen gallery improvements, and a comprehensive test suite.

**Approach:** Bump the minor version per semver — 1.0.0 → 1.1.0 — in `pubspec.yaml` and the hardcoded `applicationVersion` in `about_dialog.dart`.

## Suggested Review Order

1. [pubspec.yaml](../../pubspec.yaml#L18) — Version declaration updated from 1.0.0 to 1.1.0
2. [about_dialog.dart](../../lib/ui/widgets/dialogs/about_dialog.dart#L20) — Hardcoded `applicationVersion` synced to 1.1.0

## Verification

**Commands:**
- `flutter pub get` — expected: resolves without errors
- `flutter analyze` — expected: no new issues

**Manual checks:**
- Open the About dialog in the app — version string should display "1.1.0"
