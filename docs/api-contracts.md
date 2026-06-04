# Derpiviewer - API Contracts

**Date:** 2026-06-04
**Base URL Pattern:** `https://{booru-host}/api/v1/json/`

## Overview

Derpiviewer communicates with Philomena-powered booru APIs. Each booru (image board) is a separate host running the Philomena software. The app uses Dio as the HTTP client via a singleton `BasePhilomenaClient`.

## Supported Boorus

| Booru | Host | API Version |
|-------|------|-------------|
| derpi | derpibooru.org | v1 |
| trixie | trixiebooru.org | v1 |
| pony | ponybooru.org | v1 |
| twi | twibooru.org | v3 |
| fur | furbooru.org | v1 |
| ponerpics | ponerpics.org | v1 |
| mane | manebooru.art | v1 |

## Authentication

- **Type:** API Key (optional)
- **Parameter:** `key` query parameter
- **Source:** User-managed via `PrefModel.key`
- **Registration URL:** `https://derpibooru.org/registrations/edit`

Most endpoints work without authentication; the key enables higher rate limits and access to filtered content.

## REST API Endpoints

### 1. Fetch Single Image

```
GET https://{booru}/api/v1/json/images/{id}?key={api_key}
```

**Client Method:** `BasePhilomenaClient.fetchImage()`
**File:** `lib/api/clients.dart:15`

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| booru | Booru enum | yes | Target image board |
| id | int | yes | Image ID |
| key | String? | no | API key for authentication |

**Response:** Single `ImageResponse` object parsed from `data["image"]`.

### 2. Fetch Featured Image

```
GET https://{booru}{trending_path}?key={api_key}
```

**Client Method:** `BasePhilomenaClient.fetchFeaturedImage()`
**File:** `lib/api/clients.dart:25`

**Variance by Booru:**
- Most boorus: `/api/v1/json/images/featured` → response key: `data["image"]`
- twibooru: `/api/v3/posts/featured` → response key: `data["post"]`

### 3. Search Images

```
GET https://{booru}{search_path}?q={query}&key={api_key}&filter_id={filter_id}&page={page}&per_page={per_page}&sd={sort_direction}&sf={sort_field}
```

**Client Method:** `BasePhilomenaClient.fetchImages()`
**File:** `lib/api/clients.dart:41`

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| booru | Booru enum | yes | Target image board |
| query | String | yes | Search query string |
| key | String? | no | API key |
| filterID | int? | no | Content filter ID (default: varies by booru) |
| page | int? | no | Page number (default: 1) |
| perPage | int? | no | Results per page (default: 18) |
| sortDirection | String? | no | "desc" or "asc" |
| sortField | String? | no | Sort field name (e.g., "wilson_score", "created_at") |

**Variance by Booru:**
- Most boorus: `/api/v1/json/search/images` → response key: `data["images"]`
- twibooru: `/api/v3/search/posts` → response key: `data["posts"]`

**Response:** `List<ImageResponse>` parsed from the images/posts array.

## HTTP Client Implementation

**File:** `lib/helpers/connect.dart`

```dart
// Singleton Dio instance
class DioClient {
  static dynamic _instance;
  static Dio get instance {
    _instance ??= Dio();
    return _instance;
  }
}

// Generic GET function
Future<Map<String, dynamic>> getData({
  required String booru,
  required String path,
  Map<String, dynamic>? params,
}) async {
  final dio = DioClient.instance;
  final uri = Uri(scheme: "https", host: booru, path: path, queryParameters: params);
  final response = await dio.getUri(uri);
  if (response.statusCode == 200) return response.data;
  return {};
}
```

**Note:** Error handling is minimal — empty map `{}` is returned on any error.

## Data Transfer Object

**File:** `lib/api/do.dart`

### ImageResponse

The central DTO used across all API responses and local DB queries. Constructed via:
- `ImageResponse.fromJson(Map<String, dynamic> obj, Booru booru)` — from API JSON
- `ImageResponse.fromDbQueries(Map<String, dynamic> obj)` — from SQLite row
- `toJson()` — serialization for SQLite storage

**Key fields:** id, booru, fullUrl, smallUrl, mediumUrl, largeUrl, thumbUrl, thumbSmallUrl, thumbTinyUrl, format, tags, tagids, description, createdAt, duration, upvotes, downvotes, comments, faves, uploader, sourceUrls

### PrefParams

Search/display preference value object:
- `filterID` (int, default: 100073)
- `perPage` (int, default: 18)
- `sortDirection` (SortDirection enum, default: desc)
- `sortField` (SortField enum, default: wilsonScore)
- `filterName` (String, default: "Default")

## Known Issues

1. **Singleton coupling:** `BasePhilomenaClient` and `DioClient` are both hardcoded singletons — impossible to mock for testing
2. **Booru-specific branching:** `if (booru == Booru.twi)` checks scattered in client code; adding a new booru with different API version requires modifying the client class
3. **URL fix hack:** `ImageResponse.fromJson` contains hardcoded `ponerpics.org` URL prefix logic (line 65-73) — this domain concern leaks into the DTO
4. **Silent error swallowing:** `getData()` returns `{}` on any error with no logging or error classification
5. **No request timeout/retry:** Dio is instantiated without timeout, retry, or interceptor configuration
