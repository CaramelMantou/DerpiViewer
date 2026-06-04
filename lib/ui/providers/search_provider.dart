import 'dart:developer';

import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/repositories/image_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/search_params.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

/// SearchProvider migrated to ViewState pattern.
///
/// Injects [ImageRepository] via constructor at composition root.
/// Uses [ViewState] for loading/success/failure UI states.
/// Implements [SearchInterface] for backward compatibility with
/// [ImageGrid], [GalleryView], and [GalleryToolBar].
class SearchProvider extends ChangeNotifier implements SearchInterface {
  final ImageRepository _repository;
  final PrefModel _prefProvider;

  /// Exposed for subclass access without breaking encapsulation.
  ImageRepository get repository => _repository;
  PrefModel get prefProvider => _prefProvider;

  ViewState<List<ImageEntity>> _state = const LoadingState();
  ViewState<List<ImageEntity>> get state => _state;
  set state(ViewState<List<ImageEntity>> value) => _state = value;

  final Lock _fetchLock = Lock();
  Lock get fetchLock => _fetchLock;

  String _query = '';
  String get query => _query;
  int _page = 1;
  int get currentPage => _page;
  set currentPage(int value) => _page = value;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  set hasMore(bool value) => _hasMore = value;

  /// The current image data — only valid when state is [SuccessState].
  List<ImageEntity> _images = [];
  List<ImageEntity> get images => _images;
  set images(List<ImageEntity> value) => _images = value;

  SearchProvider(this._repository, this._prefProvider);

  /// React to changes in [PrefModel] (e.g. booru switch).
  /// Called from [ChangeNotifierProxyProvider.update].
  void onPrefsChanged(PrefModel prefs) {
    if (_query.isNotEmpty) {
      newSearch(_query, force: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Builds [SearchParams] from current [PrefModel] state and [_page].
  SearchParams _buildSearchParams() {
    return SearchParams(
      filterId: _prefProvider.params.filterID,
      perPage: _prefProvider.params.perPage,
      sortDirection: _prefProvider.params.sortDirection,
      sortField: _prefProvider.params.sortField,
      page: _page,
    );
  }

  // ---------------------------------------------------------------------------
  // Search operations
  // ---------------------------------------------------------------------------

  /// Starts a new search for [query].
  ///
  /// Sets [LoadingState], calls [ImageRepository.searchImages],
  /// then maps [Result] to [ViewState].
  ///
  /// When [force] is true, skips the early-return guard — used by
  /// [onPrefsChanged] to re-execute when filter/sort params change.
  Future<void> newSearch(String query, {bool force = false}) async {
    if (!force && query == _query && _state is SuccessState) return;
    _query = query;
    _page = 1;
    _hasMore = true;
    _state = const LoadingState();
    notifyListeners();

    await _fetchLock.synchronized(() async {
      try {
        final result = await _repository.searchImages(
          booru: _prefProvider.booru,
          query: query,
          params: _buildSearchParams(),
          apiKey: _prefProvider.key,
        );

        _state = switch (result) {
          Success(data: final images) => () {
              _images = images;
              _hasMore = images.isNotEmpty &&
                  images.length >= _prefProvider.params.perPage;
              return SuccessState(images);
            }(),
          Failure(message: final msg, type: final type) =>
            FailureState(msg, type),
        };
        notifyListeners();
      } catch (e, stack) {
        log('SearchProvider.newSearch unhandled error', error: e, stackTrace: stack);
        _state = const FailureState('An unexpected error occurred', FailureType.unknown);
        notifyListeners();
      }
    });
  }

  /// Fetches the next page of results and appends to existing data.
  ///
  /// Guarded by [_hasMore] and [_fetchLock] to prevent duplicate calls.
  @override
  Future<void> fetchMore({bool refresh = false}) async {
    if (_query.isEmpty) return;
    if (_state is LoadingState) return;
    if (!_hasMore && !refresh) return;

    await _fetchLock.synchronized(() async {
      if (_state is LoadingState) return;
      if (!_hasMore && !refresh) return;

      final savedPage = _page;
      _page = refresh ? 1 : _page + 1;

      try {
        final result = await _repository.searchImages(
          booru: _prefProvider.booru,
          query: _query,
          params: _buildSearchParams(),
          apiKey: _prefProvider.key,
        );

        switch (result) {
          case Success(data: final newImages):
            if (newImages.isEmpty) {
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
            notifyListeners();

          case Failure(message: final msg, type: final type):
            _page = savedPage;
            _hasMore = true;
            _state = FailureState(msg, type);
            notifyListeners();
        }
      } catch (e, stack) {
        log('SearchProvider.fetchMore unhandled error', error: e, stackTrace: stack);
        _page = savedPage;
        _hasMore = true;
        _state = const FailureState('An unexpected error occurred', FailureType.unknown);
        notifyListeners();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // History management (preserved from SearchModel)
  // ---------------------------------------------------------------------------

  void addHistory(String query) {
    if (!_prefProvider.history.contains(query)) {
      _prefProvider.history.add(query);
    }
    _prefProvider.historyCount = _prefProvider.history.length;
  }

  // ---------------------------------------------------------------------------
  // SearchInterface — backward compatibility
  // ---------------------------------------------------------------------------

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
}
