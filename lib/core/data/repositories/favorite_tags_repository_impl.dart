import 'dart:developer';

import 'package:derpiviewer/core/data/datasources/favorite_tags_local_source.dart';
import 'package:derpiviewer/core/domain/repositories/favorite_tags_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';

class FavoriteTagsRepositoryImpl implements FavoriteTagsRepository {
  final FavoriteTagsLocalSource _localSource;

  FavoriteTagsRepositoryImpl(this._localSource);

  @override
  Future<Result<void>> addTag(String tag) async {
    try {
      await _localSource.addTag(tag);
      return const Success<void>(null);
    } catch (e) {
      log('Failed to add favorite tag "$tag": $e', error: e);
      return Failure<void>(
        'Failed to add favorite tag: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<void>> removeTag(String tag) async {
    try {
      await _localSource.removeTag(tag);
      return const Success<void>(null);
    } catch (e) {
      log('Failed to remove favorite tag "$tag": $e', error: e);
      return Failure<void>(
        'Failed to remove favorite tag: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<List<String>>> getAllTags() async {
    try {
      final tags = await _localSource.getAllTags();
      return Success(tags);
    } catch (e) {
      log('Failed to get favorite tags: $e', error: e);
      return Failure<List<String>>(
        'Failed to get favorite tags: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }

  @override
  Future<Result<bool>> isFavorite(String tag) async {
    try {
      final exists = await _localSource.isFavorite(tag);
      return Success(exists);
    } catch (e) {
      log('Failed to check favorite status for "$tag": $e', error: e);
      return Failure<bool>(
        'Failed to check favorite status: $e',
        FailureType.unknown,
        error: e,
      );
    }
  }
}
