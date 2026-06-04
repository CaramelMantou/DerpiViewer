import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/search_params.dart';

/// Abstract interface for image data operations.
///
/// All methods return [Future<Result<T>>] for consistent error handling.
/// Implementations live in the data layer (Story 1.3).
abstract class ImageRepository {
  /// Retrieves a single image by [booru] and [id].
  Future<Result<ImageEntity>> getImage(
    Booru booru,
    int id, {
    String? apiKey,
  });

  /// Searches for images matching [query] with [params].
  Future<Result<List<ImageEntity>>> searchImages({
    required Booru booru,
    required String query,
    required SearchParams params,
    String? apiKey,
  });

  /// Retrieves the currently featured image for [booru].
  Future<Result<ImageEntity>> getFeaturedImage(
    Booru booru, {
    String? apiKey,
  });
}
