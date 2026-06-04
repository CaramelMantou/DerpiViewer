import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/data/dtos/image_dto.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/helpers/db.dart';

/// Local data source for favorites, wrapping the existing [DbHelper].
///
/// Converts between raw database operations and domain types.
/// Instance-based for testability — replaces the static [DbHelper] API.
class FavoritesLocalSource {
  /// Returns a paginated list of favorited images as [ImageEntity].
  Future<List<ImageEntity>> getFavorites(
    Booru booru,
    int page,
    int perPage,
  ) async {
    final images = await DbHelper.getFavorites(booru, page, perPage);
    return images.map((img) {
      final dto = ImageDto.fromDbQueries(img.toJson());
      return ImageEntity.fromDto(dto, booru);
    }).toList(growable: false);
  }

  /// Adds or removes an image from favorites.
  Future<void> putFavorite(
    Booru booru,
    ImageEntity entity,
    bool isFaved,
  ) async {
    // Bridge: convert ImageEntity → ImageResponse for existing DbHelper API
    final img = ImageResponse(
      entity.id,
      booru,
      entity.urls[ImageSize.full] ?? '',
      entity.urls[ImageSize.small] ?? '',
      entity.urls[ImageSize.medium] ?? '',
      entity.urls[ImageSize.large] ?? '',
      entity.urls[ImageSize.thumb] ?? '',
      entity.urls[ImageSize.thumbSmall] ?? '',
      entity.urls[ImageSize.thumbTiny] ?? '',
      entity.tags,
      entity.tagIds,
      entity.format,
      entity.description,
      entity.createdAt,
      entity.duration,
      entity.upvotes,
      entity.downvotes,
      entity.comments,
      entity.faves,
      entity.uploader,
      entity.sourceUrls,
    );
    await DbHelper.putFavorite(booru, img, isFaved);
  }

  /// Removes a favorite by ID without needing the full entity.
  Future<void> removeFavorite(Booru booru, int imageId) async {
    await DbHelper.putFavorite(
      booru,
      ImageResponse(
        imageId, booru, '', '', '', '', '', '', '',
        [], [], ContentFormat.jpg, '', '', 0.0, 0, 0, 0, 0, '', [],
      ),
      false,
    );
  }

  /// Checks whether [imageId] is favorited for [booru].
  Future<bool> getFavorite(Booru booru, int imageId) async {
    return DbHelper.getFavorite(booru, imageId);
  }
}
