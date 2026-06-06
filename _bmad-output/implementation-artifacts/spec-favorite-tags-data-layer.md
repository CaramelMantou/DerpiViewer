---
title: 'Favorite Tags Data Layer'
type: 'feature'
created: '2026-06-06'
status: 'done'
baseline_commit: '1a2b71152c66477d901714c8bec7754d5486a0d1'
context:
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Users can browse thousands of images across 7 booru hosts, each with rich tag systems. When searching or filtering, they frequently reuse the same tags (e.g., "oc:sonata", "safe", "solo"), but must retype them every time. There is no way to save commonly used tags for quick access.

**Approach:** Add a persistent, cross-booru "favorite tags" data layer using SQLite. Users long-press a tag in the image detail sheet → context menu → "Add to favorite tags" → the tag name is persisted. This spec covers only the data layer (repository interface + SQLite implementation + DI registration). UI integration is out of scope and will be done in a follow-up.

## Boundaries & Constraints

**Always:**
- Follow existing architectural patterns: `Result<T>` sealed return type, abstract repository interface → `Impl` with `try/catch`, instance-based local source wrapping static `DbHelper` methods
- Table lives in the existing `dv.db` database alongside `favourites`
- Tag names are stored as plain strings — no entity/DTO layer needed (unlike ImageEntity's complex mapping)
- New table created in `DbHelper.initDB()` via `CREATE TABLE IF NOT EXISTS` executed **unconditionally after `openDatabase` returns** (NOT inside `onCreate`). This ensures the table exists for both fresh installs and existing users upgrading from v1. Bumping the DB version + `onUpgrade` is NOT needed — `IF NOT EXISTS` handles both paths idempotently.
- DI: register as `LazySingleton` in `injection_container.dart`, constructor injection
- `snake_case` filenames, no `I` prefix on interfaces

**Ask First:**
- Tag name length limit (default: 256 characters)
- Case sensitivity for tag names (default: case-sensitive, matching Philomena API behavior)
- Maximum number of favorite tags (default: no limit)

**Never:**
- No UI components, no context menu, no widgets — this spec is data layer only
- No per-booru scoping — favorite tags are shared across all boorus
- No tag metadata (category, color, count) — only the tag name string is stored
- No import of `ui/` or `config/` in domain/data layer files

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Add a new tag | `addTag("oc:sonata")`, tag not in DB | Tag inserted, `Success<void>` | N/A |
| Add duplicate tag | `addTag("safe")`, tag already exists | `Success<void>` (idempotent — INSERT OR IGNORE) | N/A |
| Remove existing tag | `removeTag("safe")`, tag exists | Tag deleted, `Success<void>` | N/A |
| Remove non-existent tag | `removeTag("nonexistent")`, tag not in DB | `Success<void>` (idempotent — no error) | N/A |
| List all tags | `getAllTags()`, DB has 3 tags | `Success<List<String>>` with all tag names | N/A |
| List when empty | `getAllTags()`, DB has 0 tags | `Success<List<String>>` with empty list | N/A |
| Check favorite status | `isFavorite("oc:sonata")`, tag exists | `Success<bool>(true)` | N/A |
| Check non-favorite | `isFavorite("unknown")`, tag not in DB | `Success<bool>(false)` | N/A |
| Database error | Any operation, SQLite throws exception | `Failure<T>` with message + `FailureType.unknown` | Log via `developer.log()`, retry DB init |

</frozen-after-approval>

## Code Map

- `lib/helpers/db.dart` — existing `DbHelper` static class; add `favorite_tags` table + 4 static methods
- `lib/core/domain/repositories/favorite_tags_repository.dart` — **NEW** abstract interface with 4 methods
- `lib/core/data/datasources/favorite_tags_local_source.dart` — **NEW** instance wrapper around DbHelper
- `lib/core/data/repositories/favorite_tags_repository_impl.dart` — **NEW** implementation
- `lib/core/di/injection_container.dart` — register new repository + local source

## Tasks & Acceptance

**Execution:**
- [x] `lib/helpers/db.dart` — add `favorite_tags` table to `initDB()` + 4 static methods (`addFavoriteTag`, `removeFavoriteTag`, `getAllFavoriteTags`, `isFavoriteTag`) — persistence foundation
- [x] `lib/core/domain/repositories/favorite_tags_repository.dart` — create abstract interface: `addTag`, `removeTag`, `getAllTags`, `isFavorite` with `Future<Result<T>>` return types — domain contract
- [x] `lib/core/data/datasources/favorite_tags_local_source.dart` — create instance wrapper delegating to DbHelper static methods — testable data source
- [x] `lib/core/data/repositories/favorite_tags_repository_impl.dart` — create implementation with try/catch + `FailureType.unknown` error mapping — repository impl
- [x] `lib/core/di/injection_container.dart` — register `FavoriteTagsLocalSource` and `FavoriteTagsRepository` as lazy singletons — DI wiring

**Acceptance Criteria:**
- Given `flutter analyze` runs, when it completes, then zero errors on all new files
- Given the `favorite_tags` table, when `addTag` is called with a new tag, then `getAllTags` returns a list containing that tag
- Given the `favorite_tags` table, when `addTag` is called with a duplicate tag, then the operation succeeds idempotently (no duplicate rows)
- Given the `favorite_tags` table, when `removeTag` is called for an existing tag, then `isFavorite` returns false for that tag
- Given the `favorite_tags` table, when `getAllTags` is called, then it returns all tags regardless of which booru they were added from (cross-booru)

## Spec Change Log

### Loopback 1 — 2026-06-06

**Triggering finding:** All three reviewers (Blind Hunter, Edge Case Hunter, Acceptance Auditor) flagged: `CREATE TABLE IF NOT EXISTS favorite_tags` placed inside `openDatabase`'s `onCreate` callback. `onCreate` only fires on first-ever database creation — existing users upgrading from the v1 database never execute it. All CRUD operations silently fail with "no such table" swallowed by DbHelper catch blocks.

**Amendment:** Clarified the "Always" rule: CREATE TABLE must execute **unconditionally after `openDatabase` returns**, not inside `onCreate`. Added Design Notes section documenting the migration approach (no version bump needed — `IF NOT EXISTS` handles both paths).

**Known-bad state avoided:** Feature completely broken for all existing users. Tags saved but silently lost because the table doesn't exist. All DbHelper methods silently swallow the "no such table" error.

**KEEP instructions:**
- KEEP the four-method DbHelper interface with `ConflictAlgorithm.ignore` for idempotent add
- KEEP the `FavoriteTagsRepository` abstract interface with `Result<T>` return types
- KEEP the `FavoriteTagsLocalSource` instance wrapper pattern
- KEEP the `FavoriteTagsRepositoryImpl` try/catch structure with `FailureType.unknown`
- KEEP the DI registrations in `injection_container.dart`
- KEEP the `UNIQUE NOT NULL` constraint on the tag column
- KEEP `snake_case` naming and architecture layer separation
- KEEP `error: e` in `log()` calls to match the existing `favorites_repository_impl.dart` pattern
- KEEP `const Success<void>(null)` with explicit type argument for consistency with existing code

## Design Notes

### Database migration without version bump

The `favorite_tags` table uses `CREATE TABLE IF NOT EXISTS` executed **after** `openDatabase` returns — not inside `onCreate`. This works because:

1. **Fresh installs:** `onCreate` fires (creating `favourites`), then the post-open statement creates `favorite_tags`. The `IF NOT EXISTS` guard makes it idempotent.
2. **Existing users (v1):** `onCreate` does NOT fire (database file already exists), but the post-open statement still executes, creating `favorite_tags` on first launch of the new version.

This avoids a `version` bump and `onUpgrade` handler, which would be overkill for a single additive table with no schema changes to existing data.

### Error handling consistency

The `DbHelper` static methods follow the pre-existing pattern: `try/catch` → `initDB()` recovery → default return. This is consistent with the existing `getFavorites`, `putFavorite`, and `getFavorite` methods. A holistic fix for the `DbHelper` error-swallowing pattern is deferred to a future refactor.

## Suggested Review Order

**Database schema & migration — the highest-leverage decision**

- Table created unconditionally after `openDatabase` returns, not inside `onCreate` — handles both fresh installs and v1 upgrades without a version bump
  [`db.dart:51`](../../lib/helpers/db.dart#L51)

- Four static CRUD methods follow the pre-existing DbHelper pattern (try/catch → initDB recovery → default return)
  [`db.dart:121`](../../lib/helpers/db.dart#L121)

**Domain contract**

- Abstract interface defines the four operations with `Future<Result<T>>` return types — no Flutter/UI dependencies
  [`favorite_tags_repository.dart:1`](../../lib/core/domain/repositories/favorite_tags_repository.dart#L1)

**Repository implementation**

- Impl wraps `FavoriteTagsLocalSource` in try/catch, returns `Success<void>` / `Failure<unknown>` — mirrors `FavoritesRepositoryImpl`
  [`favorite_tags_repository_impl.dart:1`](../../lib/core/data/repositories/favorite_tags_repository_impl.dart#L1)

- Thin instance wrapper delegates to `DbHelper` static methods — enables constructor-injected mocks for testing
  [`favorite_tags_local_source.dart:1`](../../lib/core/data/datasources/favorite_tags_local_source.dart#L1)

**DI wiring**

- Two new lazy singletons registered alongside existing registrations, constructor injection from container
  [`injection_container.dart:29`](../../lib/core/di/injection_container.dart#L29)

## Verification

**Commands:**
- `flutter analyze` — expected: zero errors, zero warnings on new files
- `flutter test` — expected: all existing tests still pass (no regressions)
