import 'package:derpiviewer/core/data/dtos/image_dto.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/config/constants.dart';

/// Domain entity representing an image from a booru.
///
/// Immutable — all fields final. Identity-based equality on (id, booru).
/// Pure Dart — no Flutter or data-layer dependencies.
class ImageEntity {
  final int id;
  final Booru booru;
  final Map<ImageSize, String> urls;
  final ContentFormat format;
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

  const ImageEntity({
    required this.id,
    required this.booru,
    required this.urls,
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

  /// Creates an [ImageEntity] from an [ImageDto], resolving raw types.
  factory ImageEntity.fromDto(ImageDto dto, Booru booru) {
    final formatIndex = formatExtensions.indexOf(dto.format);
    final contentFormat = formatIndex >= 0
        ? ContentFormat.values[formatIndex]
        : ContentFormat.jpg;

    return ImageEntity(
      id: dto.id,
      booru: booru,
      urls: {
        ImageSize.full: dto.fullUrl,
        ImageSize.large: dto.largeUrl,
        ImageSize.medium: dto.mediumUrl,
        ImageSize.small: dto.smallUrl,
        ImageSize.thumb: dto.thumbUrl,
        ImageSize.thumbSmall: dto.thumbSmallUrl,
        ImageSize.thumbTiny: dto.thumbTinyUrl,
      },
      format: contentFormat,
      tags: List.unmodifiable(dto.tags),
      tagIds: List.unmodifiable(dto.tagIds),
      description: dto.description,
      createdAt: dto.createdAt,
      duration: dto.duration,
      upvotes: dto.upvotes,
      downvotes: dto.downvotes,
      comments: dto.comments,
      faves: dto.faves,
      uploader: dto.uploader,
      sourceUrls: List.unmodifiable(dto.sourceUrls),
    );
  }

  /// Convenience getter: URL for a specific [ImageSize].
  String? urlForSize(ImageSize size) => urls[size];

  @override
  bool operator ==(Object other) =>
      other is ImageEntity && other.id == id && other.booru == booru;

  @override
  int get hashCode => Object.hash(id, booru);
}
