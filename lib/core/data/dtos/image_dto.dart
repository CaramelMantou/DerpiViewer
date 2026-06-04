import 'dart:convert';

import 'package:derpiviewer/core/domain/enums/booru.dart';

/// Data transfer object for image JSON parsing and SQLite serialization.
///
/// Mirrors the existing [ImageResponse] shape. Used by [BooruApiStrategy]
/// implementations to parse API responses and by [FavoritesLocalSource]
/// for database reads/writes.
class ImageDto {
  final int id;
  final int booruIndex;
  final String fullUrl;
  final String smallUrl;
  final String mediumUrl;
  final String largeUrl;
  final String thumbUrl;
  final String thumbSmallUrl;
  final String thumbTinyUrl;
  final String format;
  final List<String> tags;
  final List<int> tagIds;
  final String description;
  final String createdAt;
  final double duration;
  final int upvotes;
  final int downvotes;
  final int comments;
  final int faves;
  final String uploader;
  final List<String> sourceUrls;

  const ImageDto({
    required this.id,
    required this.booruIndex,
    required this.fullUrl,
    required this.smallUrl,
    required this.mediumUrl,
    required this.largeUrl,
    required this.thumbUrl,
    required this.thumbSmallUrl,
    required this.thumbTinyUrl,
    required this.format,
    required this.tags,
    required this.tagIds,
    required this.description,
    required this.createdAt,
    required this.duration,
    required this.upvotes,
    required this.downvotes,
    required this.comments,
    required this.faves,
    required this.uploader,
    required this.sourceUrls,
  });

  /// Parses an API JSON response into an [ImageDto].
  factory ImageDto.fromJson(Map<String, dynamic> obj, Booru booru) {
    var representations = obj["representations"] as Map<String, dynamic>;
    String full = representations["full"] as String;
    String small = representations["small"] as String;
    String medium = representations["medium"] as String;
    String large = representations["large"] as String;
    String thumb = representations["thumb"] as String;
    String thumbSmall = representations["thumb_small"] as String;
    String thumbTiny = representations["thumb_tiny"] as String;

    // Replace .webm thumbnails with .gif for video formats
    final fmt = obj["format"] as String? ?? "";
    if (fmt == "webm" || fmt == "mp4") {
      thumb = thumb.replaceFirst(".webm", ".gif");
      thumbSmall = thumbSmall.replaceFirst(".webm", ".gif");
      thumbTiny = thumbTiny.replaceFirst(".webm", ".gif");
    }

    // Fix relative URLs (ponerpics.org)
    if (full.startsWith("/")) {
      full = "https://ponerpics.org$full";
      small = "https://ponerpics.org$small";
      medium = "https://ponerpics.org$medium";
      large = "https://ponerpics.org$large";
      thumb = "https://ponerpics.org$thumb";
      thumbSmall = "https://ponerpics.org$thumbSmall";
      thumbTiny = "https://ponerpics.org$thumbTiny";
    }

    return ImageDto(
      id: obj["id"] as int,
      booruIndex: booru.index,
      fullUrl: full,
      smallUrl: small,
      mediumUrl: medium,
      largeUrl: large,
      thumbUrl: thumb,
      thumbSmallUrl: thumbSmall,
      thumbTinyUrl: thumbTiny,
      format: fmt,
      tags: List<String>.from(obj["tags"] ?? []),
      tagIds: List<int>.from(obj["tag_ids"] ?? []),
      description: obj["description"] as String? ?? "",
      createdAt: obj["created_at"] as String? ?? "",
      duration: (obj["duration"] as num?)?.toDouble() ?? 0.0,
      upvotes: obj["upvotes"] as int? ?? 0,
      downvotes: obj["downvotes"] as int? ?? 0,
      comments: obj["comment_count"] as int? ?? 0,
      faves: obj["faves"] as int? ?? 0,
      uploader: obj["uploader"] as String? ?? "",
      sourceUrls: List<String>.from(obj["source_urls"] ?? []),
    );
  }

  /// Parses a database row into an [ImageDto].
  factory ImageDto.fromDbQueries(Map<String, dynamic> obj) {
    return ImageDto(
      id: obj["id"] as int,
      booruIndex: obj["booru"] as int,
      fullUrl: obj["full"] as String? ?? "",
      smallUrl: obj["small"] as String? ?? "",
      mediumUrl: obj["medium"] as String? ?? "",
      largeUrl: obj["large"] as String? ?? "",
      thumbUrl: obj["thumb"] as String? ?? "",
      thumbSmallUrl: obj["thumbsmall"] as String? ?? "",
      thumbTinyUrl: obj["thumbtiny"] as String? ?? "",
      format: obj["format"] as String? ?? "",
      tags: List<String>.from(const JsonDecoder().convert(obj["tags"] as String)),
      tagIds: List<int>.from(const JsonDecoder().convert(obj["tagids"] as String)),
      description: obj["description"] as String? ?? "",
      createdAt: obj["createdat"] as String? ?? "",
      duration: (obj["duration"] as num?)?.toDouble() ?? 0.0,
      upvotes: obj["upvotes"] as int? ?? 0,
      downvotes: obj["downvotes"] as int? ?? 0,
      comments: obj["comments"] as int? ?? 0,
      faves: obj["faves"] as int? ?? 0,
      uploader: obj["uploader"] as String? ?? "",
      sourceUrls: List<String>.from(const JsonDecoder().convert(obj["sources"] as String)),
    );
  }

  /// Serializes to a map suitable for SQLite insertion.
  Map<String, dynamic> toJson() => {
        "id": id,
        "booru": booruIndex,
        "full": fullUrl,
        "small": smallUrl,
        "medium": mediumUrl,
        "large": largeUrl,
        "thumb": thumbUrl,
        "thumbsmall": thumbSmallUrl,
        "thumbtiny": thumbTinyUrl,
        "format": format,
        "tags": const JsonEncoder().convert(tags),
        "tagids": const JsonEncoder().convert(tagIds),
        "description": description,
        "createdat": createdAt,
        "duration": duration,
        "upvotes": upvotes,
        "downvotes": downvotes,
        "comments": comments,
        "faves": faves,
        "uploader": uploader,
        "sources": const JsonEncoder().convert(sourceUrls),
      };
}
