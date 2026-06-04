import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/result.dart';

/// Abstract interface for favorites data operations.
///
/// All methods return [Future<Result<T>>] for consistent error handling.
/// Implementations live in the data layer (Story 1.3).
abstract class FavoritesRepository {
  /// Returns a paginated list of favorited images for [booru].
  Future<Result<List<ImageEntity>>> getFavorites(
    Booru booru,
    int page,
    int perPage,
  );

  /// Adds or removes an image from favorites by [imageId].
  Future<Result<void>> toggleFavorite(
    Booru booru,
    int imageId,
    bool isFaved,
  );

  /// Checks whether [imageId] is favorited.
  Future<Result<bool>> isFavorite(
    Booru booru,
    int imageId,
  );
}
