import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:derpiviewer/core/data/datasources/strategies/booru_api_strategy.dart';
import 'package:derpiviewer/core/data/dtos/image_dto.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';

/// Philomena v1 API strategy.
///
/// Used by: derpibooru, trixiebooru, ponybooru, furbooru, ponerpics, manebooru.
/// Search: `/api/v1/json/search/images` → `data["images"]`
/// Featured: `/api/v1/json/images/featured` → `data["image"]`
class PhilomenaV1Strategy implements BooruApiStrategy {
  final String _host;
  final Booru _booru;
  late final Dio _dio;

  PhilomenaV1Strategy(this._host, this._booru) {
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
  String get searchPath => '/api/v1/json/search/images';

  @override
  String get trendingPath => '/api/v1/json/images/featured';

  @override
  String imagePath(int id) => '/api/v1/json/images/$id';

  @override
  List<ImageDto> parseImageList(Map<String, dynamic> json) {
    final images = json["images"] as List<dynamic>;
    return images
        .map((e) => ImageDto.fromJson(e as Map<String, dynamic>, _booru))
        .toList(growable: false);
  }

  @override
  ImageDto parseImage(Map<String, dynamic> json) {
    return ImageDto.fromJson(json["image"] as Map<String, dynamic>, _booru);
  }

  @override
  ImageDto parseFeatured(Map<String, dynamic> json) {
    return ImageDto.fromJson(json["image"] as Map<String, dynamic>, _booru);
  }
}

/// Dio interceptor that retries on transient network errors with exponential backoff.
///
/// Uses the original [Dio] instance so that timeout settings and headers
/// are preserved across retries. Retries on connectTimeout, sendTimeout,
/// receiveTimeout, and connection-level other errors.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
      if (retryCount < maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        await Future.delayed(Duration(seconds: 1 << (retryCount + 1)));
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          // fall through to handler.next
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioError err) =>
      err.type == DioErrorType.connectTimeout ||
      err.type == DioErrorType.sendTimeout ||
      err.type == DioErrorType.receiveTimeout ||
      err.type == DioErrorType.other;
}
