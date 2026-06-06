import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/core/domain/search_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

/// FavoritesProvider migrated to ViewState pattern.
///
/// Injects [FavoritesRepository] via constructor at composition root.
/// Uses [ViewState] for loading/success/failure UI states.
/// Implements [SearchInterface] for backward compatibility with
/// [ImageGrid], [GalleryView], and [GalleryToolBar].
class FavoritesProvider extends ChangeNotifier implements SearchInterface {
  final FavoritesRepository _repository;
  final PrefModel _prefProvider;

  PrefModel get prefProvider => _prefProvider;

  ViewState<List<ImageEntity>> _state = const LoadingState();
  ViewState<List<ImageEntity>> get state => _state;

  final Lock _fetchLock = Lock();

  int _page = 1;
  bool _hasMore = true;

  /// The current image data — only valid when state is [SuccessState].
  List<ImageEntity> _images = [];

  FavoritesProvider(this._repository, this._prefProvider);

  /// Called when a favorite is toggled elsewhere to force a refresh.
  void changeFav() {
    unawaited(_fetchResult(refresh: true));
  }

  Future<void> _fetchResult({bool refresh = false}) async {
    await _fetchLock.synchronized(() async {
      if (!_hasMore && !refresh) return;

      final savedPage = _page;
      _page = refresh ? 1 : _page + 1;

      if (refresh || _images.isEmpty) {
        _state = const LoadingState();
        notifyListeners();
      }

      try {
        final result = await _repository.getFavorites(
          _prefProvider.booru,
          _page,
          _prefProvider.params.perPage,
        );

        switch (result) {
          case Success(data: final newImages):
            if (newImages.isEmpty && !refresh) {
              _hasMore = false;
              return;
            }
            if (refresh) {
              _images = newImages;
            } else {
              _images = [..._images, ...newImages];
            }
            _hasMore =
                newImages.length >= _prefProvider.params.perPage;
            _state = SuccessState(_images);

          case Failure(message: final msg, type: final type):
            _page = savedPage;
            if (refresh || _images.isEmpty) {
              _state = FailureState(msg, type);
            } else {
              _hasMore = true;
            }
        }
      } catch (e, stack) {
        log('FavoritesProvider._fetchResult unhandled error',
            error: e, stackTrace: stack);
        _page = savedPage;
        if (refresh || _images.isEmpty) {
          _state = const FailureState(
              'An unexpected error occurred', FailureType.unknown);
        } else {
          _hasMore = true;
        }
      } finally {
        notifyListeners();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // SearchInterface
  // ---------------------------------------------------------------------------

  @override
  Future<void> fetchMore({bool refresh = false}) {
    return _fetchResult(refresh: refresh);
  }

  @override
  int getItemCount() => _images.length;

  @override
  int getItemID(int index) => _images[index].id;

  @override
  ContentFormat getItemFormat(int index) => _images[index].format;

  @override
  Booru getBooru() => _prefProvider.booru;

  @override
  PrefModel getPref() => _prefProvider;

  @override
  ImageResponse getItem(int index) {
    final e = _images[index];
    return ImageResponse.fromEntity(
      id: e.id,
      booru: e.booru,
      fullUrl: e.urlForSize(ImageSize.full) ?? '',
      smallUrl: e.urlForSize(ImageSize.small) ?? '',
      mediumUrl: e.urlForSize(ImageSize.medium) ?? '',
      largeUrl: e.urlForSize(ImageSize.large) ?? '',
      thumbUrl: e.urlForSize(ImageSize.thumb) ?? '',
      thumbSmallUrl: e.urlForSize(ImageSize.thumbSmall) ?? '',
      thumbTinyUrl: e.urlForSize(ImageSize.thumbTiny) ?? '',
      format: e.format,
      tags: List<String>.from(e.tags),
      tagids: List<int>.from(e.tagIds),
      description: e.description,
      createdAt: e.createdAt,
      duration: e.duration,
      upvotes: e.upvotes,
      downvotes: e.downvotes,
      comments: e.comments,
      faves: e.faves,
      uploader: e.uploader,
      sourceUrls: List<String>.from(e.sourceUrls),
    );
  }

  @override
  String getItemUrl(int index, ImageSize imageSize) {
    final entity = _images[index];
    final url = entity.urlForSize(imageSize);
    return url ?? entity.urlForSize(ImageSize.thumb) ?? '';
  }

  @override
  String getItemMediumThumbUrl(int index) {
    final entity = _images[index];
    if (entity.format == ContentFormat.mp4 ||
        entity.format == ContentFormat.webm) {
      return entity.urlForSize(ImageSize.thumb) ?? '';
    } else {
      return entity.urlForSize(ImageSize.medium) ?? '';
    }
  }

  @override
  String getItemThumbUrl(int index) {
    final entity = _images[index];
    if (entity.format == ContentFormat.mp4 ||
        entity.format == ContentFormat.webm) {
      return entity.urlForSize(ImageSize.thumb) ?? '';
    } else {
      return entity.urlForSize(ImageSize.small) ?? '';
    }
  }
}
