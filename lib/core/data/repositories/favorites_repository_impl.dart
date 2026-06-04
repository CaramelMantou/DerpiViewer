import 'dart:developer';

import 'package:derpiviewer/core/data/datasources/favorites_local_source.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';

/// Concrete implementation of [FavoritesRepository] using [FavoritesLocalSource].
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalSource _localSource;

  FavoritesRepositoryImpl(this._localSource);

  @override
  Future<Result<List<ImageEntity>>> getFavorites(
    Booru booru,
    int page,
    int perPage,
  ) async {
    try {
      final entities = await _localSource.getFavorites(booru, page, perPage);
      return Success<List<ImageEntity>>(entities);
    } catch (e) {
      log('getFavorites error: $e', error: e);
      return Failure<List<ImageEntity>>(
        'Failed to load favorites: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<void>> toggleFavorite(
    Booru booru,
    int imageId,
    bool isFaved,
  ) async {
    try {
      if (isFaved) {
        // INSERT requires the full ImageEntity (URLs, tags, etc.).
        // Callers must use addToFavorites() with a complete entity.
        return Failure<void>(
          'Cannot add favorite by ID alone — use addToFavorites(ImageEntity) to provide full image data',
          FailureType.unknown,
        );
      } else {
        // DELETE only needs (id, booru) — safe with ID-only call.
        await _localSource.removeFavorite(booru, imageId);
      }
      return const Success<void>(null);
    } catch (e) {
      log('toggleFavorite error: $e', error: e);
      return Failure<void>(
        'Failed to toggle favorite: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<bool>> isFavorite(
    Booru booru,
    int imageId,
  ) async {
    try {
      final result = await _localSource.getFavorite(booru, imageId);
      return Success<bool>(result);
    } catch (e) {
      log('isFavorite error: $e', error: e);
      return Failure<bool>(
        'Failed to check favorite: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }
}
