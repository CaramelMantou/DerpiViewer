# Derpiviewer - Data Models

**Date:** 2026-06-04

## Overview

The app uses a mixed data approach: remote Philomena API data consumed as `ImageResponse` objects, and a local SQLite database for favorites persistence. User preferences are stored via `shared_preferences`.

## Entity-Relationship Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Philomena API  │────▶│  ImageResponse   │────▶│  SQLite DB   │
│  (Remote)       │     │  (In-Memory)     │     │  (Favorites) │
└─────────────────┘     └──────────────────┘     └──────────────┘
                                                         │
                                ┌────────────────────────┘
                                ▼
                        ┌──────────────┐
                        │ SharedPrefs  │
                        │ (Settings)   │
                        └──────────────┘
```

## ImageResponse (Core Entity)

**File:** `lib/api/do.dart`

The central data object representing a booru image. Serves dual purpose as both API DTO and database entity.

| Field | Type | Source (API) | Source (DB) | Description |
|-------|------|-------------|-------------|-------------|
| id | int | obj["id"] | obj["id"] | Unique image ID |
| booru | Booru | parameter | obj["booru"] | Source image board |
| fullUrl | String | representations.full | obj["full"] | Full resolution URL |
| smallUrl | String | representations.small | obj["small"] | Small resolution URL |
| mediumUrl | String | representations.medium | obj["medium"] | Medium resolution URL |
| largeUrl | String | representations.large | obj["large"] | Large resolution URL |
| thumbUrl | String | representations.thumb | obj["thumb"] | Thumbnail URL |
| thumbSmallUrl | String | representations.thumb_small | obj["thumbsmall"] | Small thumbnail URL |
| thumbTinyUrl | String | representations.thumb_tiny | obj["thumbtiny"] | Tiny thumbnail URL |
| format | ContentFormat | obj["format"] | obj["format"] | Image/video format enum |
| tags | List\<String\> | obj["tags"] | JSON-decoded | Tag names |
| tagids | List\<int\> | obj["tag_ids"] | JSON-decoded | Tag IDs |
| description | String | obj["description"] | obj["description"] | Markdown description |
| createdAt | String | obj["created_at"] | obj["createdat"] | Creation timestamp (RFC3339) |
| duration | double | obj["duration"] | obj["duration"] | Duration in seconds |
| upvotes | int | obj["upvotes"] | obj["upvotes"] | Upvote count |
| downvotes | int | obj["downvotes"] | obj["downvotes"] | Downvote count |
| comments | int | obj["comment_count"] | obj["comments"] | Comment count |
| faves | int | obj["faves"] | obj["faves"] | Favorite count |
| uploader | String | obj["uploader"] | obj["uploader"] | Uploader name |
| sourceUrls | List\<String\> | obj["source_urls"] | JSON-decoded | Source URL list |

### Constructor Variants

1. **Positional constructor** — `ImageResponse(id, booru, fullUrl, ...)` — all 19 fields (rarely used directly)
2. **fromJson** — Parses API JSON response, includes:
   - `.webm` → `.gif` replacement for video thumbnails
   - `ponerpics.org` URL prefix fix for relative URLs
3. **fromDbQueries** — Parses SQLite row, decodes JSON-stored lists
4. **toJson** — Serializes for SQLite storage with JSON-encoded lists

## PrefParams (Preference Value Object)

**File:** `lib/api/do.dart:137`

Configuration value object for search/display parameters:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| filterID | int | 100073 | Content filter identifier |
| perPage | int | 18 | Results per page |
| sortDirection | SortDirection | desc | Sort order direction |
| sortField | SortField | wilsonScore | Field to sort by |
| filterName | String | "Default" | Human-readable filter name |

## SQLite Schema

**File:** `lib/helpers/db.dart`
**Database:** `dv.db` in external storage or app documents directory

### Table: `favourites`

```sql
CREATE TABLE IF NOT EXISTS favourites (
    id INTEGER,
    booru INTEGER,
    full VARCHAR(64),
    small VARCHAR(64),
    medium VARCHAR(64),
    large VARCHAR(64),
    thumb VARCHAR(64),
    thumbsmall VARCHAR(64),
    thumbtiny VARCHAR(64),
    format VARCHAR(32),
    tags TEXT,           -- JSON array of strings
    tagids TEXT,         -- JSON array of integers
    description TEXT,
    createdat VARCHAR(64),
    duration DOUBLE,
    upvotes INTEGER,
    downvotes INTEGER,
    comments INTEGER,
    faves INTEGER,
    uploader VARCHAR(64),
    sources TEXT         -- JSON array of strings
)
```

**Note:** No primary key or unique constraint is defined. The composite `(id, booru)` is used in WHERE clauses for lookups but is not enforced at the schema level.

### Operations

| Operation | Method | Query Pattern |
|-----------|--------|---------------|
| Get Favorites (paginated) | `getFavorites(booru, page, perpage)` | SELECT with WHERE booru, LIMIT, OFFSET |
| Add/Update Favorite | `putFavorite(booru, image, faved)` | INSERT OR REPLACE |
| Remove Favorite | `putFavorite(booru, image, false)` | DELETE WHERE id AND booru |
| Check Favorite | `getFavorite(booru, itemID)` | SELECT WHERE id AND booru |

## App Preferences (SharedPreferences)

**File:** `lib/models/pref_model.dart`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| booru | int | 1 (trixie) | Current image board |
| key | String | "" | API key |
| filter_name | String | "Default" | Selected filter name |
| per_page | int | 18 | Results per page |
| sd | int | 0 (desc) | Sort direction index |
| sf | int | 0 (wilsonScore) | Sort field index |
| image_size | int | 4 (full) | Image display size index |
| video_size | int | 2 (medium) | Video display size index |
| download_size | int | 4 (full) | Download size index |
| share_size | int | 4 (full) | Share size index |
| is_dark_mode | bool | false | Dark mode toggle |

## Known Issues

1. **No primary key on favourites table** — duplicates possible; composite key `(id, booru)` should be enforced
2. **ImageResponse is both DTO and entity** — couples API contract to DB schema; changes to either force changes to both
3. **List fields stored as JSON strings** — tags, tagids, sources stored as JSON in SQLite TEXT columns; no queryability
4. **VARCHAR(64) for URLs** — too short; many image URLs exceed 64 characters (though SQLite ignores length constraints)
5. **No migration strategy** — `initDB` creates a fresh table with no version migration path
6. **PrefModel.getPref() is async but called from constructor** — the Future is fire-and-forget; UI may render before preferences are loaded
