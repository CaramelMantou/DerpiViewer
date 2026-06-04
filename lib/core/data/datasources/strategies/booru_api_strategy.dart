import 'package:dio/dio.dart';
import 'package:derpiviewer/core/data/dtos/image_dto.dart';

/// Abstract strategy for booru-specific API behavior.
abstract class BooruApiStrategy {
  /// The booru's host domain (e.g. "derpibooru.org").
  String get host;

  /// API path for search queries.
  String get searchPath;

  /// API path for featured/trending images.
  String get trendingPath;

  /// API path for single image detail requests.
  String imagePath(int id);

  /// The configured Dio HTTP client for this strategy.
  Dio get dio;

  /// Parses a list of images from the search JSON response.
  List<ImageDto> parseImageList(Map<String, dynamic> json);

  /// Parses a single image from the detail JSON response.
  ImageDto parseImage(Map<String, dynamic> json);

  /// Parses a featured image from the trending JSON response.
  ImageDto parseFeatured(Map<String, dynamic> json);
}
