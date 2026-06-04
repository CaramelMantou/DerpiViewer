import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/repositories/image_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/search_params.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/ui/providers/search_provider.dart';

/// TrendingProvider migrated to ViewState pattern.
///
/// Extends [SearchProvider] for [SearchInterface] compatibility with
/// [ImageGrid], [GalleryView], and [GalleryToolBar].
///
/// Manages TWO ViewStates:
/// - [featuredState]: for the featured image banner at the top
/// - [state]: inherited from SearchProvider, for the trending image grid
///
/// Injects [ImageRepository] via constructor at composition root.
class TrendingProvider extends SearchProvider {
  ViewState<ImageEntity> _featuredState = const LoadingState();
  ViewState<ImageEntity> get featuredState => _featuredState;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  TrendingProvider(ImageRepository repository, PrefModel prefs)
      : super(repository, prefs);

  /// React to changes in [PrefModel] (e.g. booru switch).
  /// Called from [ChangeNotifierProxyProvider.update].
  @override
  void onPrefsChanged(PrefModel prefs) {
    unawaited(fetchMore(refresh: true).catchError((Object e) {
      log('TrendingProvider.onPrefsChanged fetchMore failed', error: e);
      return null;
    }));
  }

  // ---------------------------------------------------------------------------
  // Trending fetchMore — overrides SearchProvider.fetchMore
  // ---------------------------------------------------------------------------

  @override
  Future<void> fetchMore({bool refresh = false}) async {
    log('TrendingProvider.fetchMore refresh=$refresh');

    await fetchLock.synchronized(() async {
      // Guard: allow refresh through, block load-more when loading
      if (!hasMore && !refresh) return;
      if (!refresh && (_isLoadingMore || state is LoadingState)) return;
      if (refresh && state is LoadingState) return;

      if (refresh) {
        _featuredState = const LoadingState();
        state = const LoadingState();
      } else {
        _isLoadingMore = true;
      }

      final savedPage = currentPage;
      currentPage = refresh ? 1 : currentPage + 1;

      try {
        // Fetch featured image on refresh (first load)
        if (refresh) {
          final featured = await repository.getFeaturedImage(
            prefProvider.booru,
            apiKey: prefProvider.key,
          );
          _featuredState = switch (featured) {
            Success(data: final img) => SuccessState(img),
            Failure(message: final msg, type: final type) =>
              FailureState(msg, type),
          };
        }

        // Fetch trending images using featuredQuery
        final result = await repository.searchImages(
          booru: prefProvider.booru,
          query: prefProvider.featuredQuery,
          params: SearchParams(
            filterId: prefProvider.params.filterID,
            perPage: prefProvider.params.perPage,
            sortDirection: prefProvider.params.sortDirection,
            sortField: prefProvider.params.sortField,
            page: currentPage,
          ),
          apiKey: prefProvider.key,
        );

        switch (result) {
          case Success(data: final newImages):
            if (newImages.isEmpty) {
              hasMore = false;
              if (refresh) {
                images = [];
                state = const SuccessState([]);
              }
              return;
            }
            if (refresh) {
              images = newImages;
            } else {
              images = [...images, ...newImages];
            }
            hasMore =
                newImages.length >= prefProvider.params.perPage;
            state = SuccessState(images);

          case Failure(message: final msg, type: final type):
            currentPage = savedPage;

            if (refresh || images.isEmpty) {
              // First-load error: show ErrorView
              state = FailureState(msg, type);
            } else {
              // FetchMore error with existing content: keep data,
              // re-throw so the UI layer can show a snackbar
              hasMore = true;
              _isLoadingMore = false;
              notifyListeners();
              throw FetchMoreException(msg, type);
            }
        }
      } catch (e) {
        if (e is FetchMoreException) {
          rethrow;
        }
        log('TrendingProvider.fetchMore unhandled error', error: e);
        currentPage = savedPage;
        if (refresh || images.isEmpty) {
          state = const FailureState(
              'An unexpected error occurred', FailureType.unknown);
        } else {
          hasMore = true;
          _isLoadingMore = false;
          notifyListeners();
          throw const FetchMoreException(
              'An unexpected error occurred', FailureType.unknown);
        }
      } finally {
        _isLoadingMore = false;
        notifyListeners();
      }
    });
  }
}

/// Internal exception to distinguish fetchMore errors from first-load errors.
class FetchMoreException implements Exception {
  final String message;
  final FailureType type;
  const FetchMoreException(this.message, this.type);

  @override
  String toString() => 'FetchMoreException: $message ($type)';
}
