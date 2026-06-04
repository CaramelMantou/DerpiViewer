import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:derpiviewer/core/data/datasources/strategies/booru_api_strategy_factory.dart';
import 'package:derpiviewer/core/data/error_mapper.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/repositories/image_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/search_params.dart';
import 'package:derpiviewer/enums.dart';

/// Concrete implementation of [ImageRepository] using the BooruApiStrategy pattern.
class ImageRepositoryImpl implements ImageRepository {
  @override
  Future<Result<ImageEntity>> getImage(
    Booru booru,
    int id, {
    String? apiKey,
  }) async {
    try {
      final host = ConstStrings.boorus[booru] ?? ConstStrings.defaultHost;
      final strategy = BooruApiStrategyFactory.create(booru, host);
      final queryParams = <String, String>{
        if (apiKey != null && apiKey.isNotEmpty) 'key': apiKey,
      };
      final uri = Uri(
        scheme: 'https',
        host: host,
        path: strategy.imagePath(id),
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      log(uri.toString());
      final response = await strategy.dio.getUri(uri);
      final data = response.data as Map<String, dynamic>;
      final dto = strategy.parseImage(data);
      return Success<ImageEntity>(ImageEntity.fromDto(dto, booru));
    } on DioError catch (e) {
      log('ImageRepository getImage error: ${e.message}', error: e);
      return mapDioError(e) as Failure<ImageEntity>;
    } catch (e) {
      return Failure<ImageEntity>(
        'Unexpected error: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<List<ImageEntity>>> searchImages({
    required Booru booru,
    required String query,
    required SearchParams params,
    String? apiKey,
  }) async {
    try {
      final host = ConstStrings.boorus[booru] ?? ConstStrings.defaultHost;
      final strategy = BooruApiStrategyFactory.create(booru, host);
      final queryParams = <String, String>{
        'q': query,
        'page': '${params.page}',
        'per_page': '${params.perPage}',
        'sd': ConstStrings.sds[params.sortDirection.index],
        'sf': ConstStrings.sfs[params.sortField.index],
      };
      if (apiKey != null && apiKey.isNotEmpty) {
        queryParams['key'] = apiKey;
      }
      if (params.filterId != null) {
        queryParams['filter_id'] = '${params.filterId}';
      }
      final uri = Uri(
        scheme: 'https',
        host: host,
        path: strategy.searchPath,
        queryParameters: queryParams,
      );
      log(uri.toString());
      final response = await strategy.dio.getUri(uri);
      final data = response.data as Map<String, dynamic>;
      if (data.isEmpty) return const Success<List<ImageEntity>>([]);
      final dtos = strategy.parseImageList(data);
      final entities =
          dtos.map((d) => ImageEntity.fromDto(d, booru)).toList(growable: false);
      return Success<List<ImageEntity>>(entities);
    } on DioError catch (e) {
      log('ImageRepository search error: ${e.message}', error: e);
      return mapDioError(e) as Failure<List<ImageEntity>>;
    } catch (e) {
      return Failure<List<ImageEntity>>(
        'Unexpected error: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<ImageEntity>> getFeaturedImage(
    Booru booru, {
    String? apiKey,
  }) async {
    try {
      final host = ConstStrings.boorus[booru] ?? ConstStrings.defaultHost;
      final strategy = BooruApiStrategyFactory.create(booru, host);
      final queryParams = <String, String>{
        if (apiKey != null && apiKey.isNotEmpty) 'key': apiKey,
      };
      final uri = Uri(
        scheme: 'https',
        host: host,
        path: strategy.trendingPath,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      log(uri.toString());
      final response = await strategy.dio.getUri(uri);
      final data = response.data as Map<String, dynamic>;
      final dto = strategy.parseFeatured(data);
      return Success<ImageEntity>(ImageEntity.fromDto(dto, booru));
    } on DioError catch (e) {
      log('ImageRepository featured error: ${e.message}', error: e);
      return mapDioError(e) as Failure<ImageEntity>;
    } catch (e) {
      return Failure<ImageEntity>(
        'Unexpected error: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }
}
