import 'package:dio/dio.dart';
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
  /// An optional [cancelToken] cancels the in-flight request.
  Future<Result<ImageEntity>> getImage(
    Booru booru,
    int id, {
    String? apiKey,
    CancelToken? cancelToken,
  });

  /// Searches for images matching [query] with [params].
  /// An optional [cancelToken] cancels the in-flight request.
  Future<Result<List<ImageEntity>>> searchImages({
    required Booru booru,
    required String query,
    required SearchParams params,
    String? apiKey,
    CancelToken? cancelToken,
  });

  /// Retrieves the currently featured image for [booru].
  /// An optional [cancelToken] cancels the in-flight request.
  Future<Result<ImageEntity>> getFeaturedImage(
    Booru booru, {
    String? apiKey,
    CancelToken? cancelToken,
  });
}
