import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:derpiviewer/core/data/datasources/strategies/booru_api_strategy.dart';
import 'package:derpiviewer/core/data/datasources/strategies/philomena_v1_strategy.dart';
import 'package:derpiviewer/core/data/dtos/image_dto.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';

/// Philomena v3 API strategy.
///
/// Used by: twibooru.
/// Search: `/api/v3/search/posts` → `data["posts"]`
/// Featured: `/api/v3/posts/featured` → `data["post"]`
class PhilomenaV3Strategy implements BooruApiStrategy {
  final String _host;
  final Booru _booru;
  late final Dio _dio;

  PhilomenaV3Strategy(this._host, this._booru) {
    _dio = Dio(BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 30000,
    ));
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => log(o.toString()),
      ),
      RetryInterceptor(dio: _dio, maxRetries: 3),
    ]);
  }

  @override
  Dio get dio => _dio;

  @override
  String get host => _host;

  @override
  String get searchPath => '/api/v3/search/posts';

  @override
  String get trendingPath => '/api/v3/posts/featured';

  @override
  String imagePath(int id) => '/api/v3/posts/$id';

  @override
  List<ImageDto> parseImageList(Map<String, dynamic> json) {
    final posts = json["posts"] as List<dynamic>;
    return posts
        .map((e) => ImageDto.fromJson(e as Map<String, dynamic>, _booru))
        .toList(growable: false);
  }

  @override
  ImageDto parseImage(Map<String, dynamic> json) {
    return ImageDto.fromJson(json["post"] as Map<String, dynamic>, _booru);
  }

  @override
  ImageDto parseFeatured(Map<String, dynamic> json) {
    return ImageDto.fromJson(json["post"] as Map<String, dynamic>, _booru);
  }
}
