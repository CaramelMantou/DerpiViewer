import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:derpiviewer/config/constants.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/pages/search_page.dart';
import 'package:derpiviewer/ui/providers/trending_provider.dart';
import 'package:derpiviewer/ui/widgets/dialogs/api_key_dialog.dart';
import 'package:derpiviewer/ui/widgets/error_view.dart';
import 'package:derpiviewer/ui/widgets/skeleton_grid.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrendingScroll extends StatefulWidget {
  const TrendingScroll({super.key});
  @override
  State<TrendingScroll> createState() => _TrendingScrollState();
}

class _TrendingScrollState extends State<TrendingScroll> {
  late ScrollController _scrollController;
  bool _apiSnackbarShown = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollCallback);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final trending = Provider.of<TrendingProvider>(context, listen: false);
      // Skip if onPrefsChanged already triggered initial load (avoids
      // double fetch + skeleton flicker). SuccessState = already loaded;
      // LoadingState = onPrefsChanged's fetchMore is in progress.
      if (trending.state is SuccessState) return;
      if (trending.state is LoadingState) return;
      trending.fetchMore(refresh: true).catchError((Object e) {
        log('Initial trending fetch failed', error: e);
        return null;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollCallback);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollCallback() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final trending = Provider.of<TrendingProvider>(context, listen: false);
      trending.fetchMore().catchError((Object e) {
        if (e is FetchMoreException) {
          _showFetchMoreError(trending);
        }
        return null;
      });
    }
  }

  void _showFetchMoreError(TrendingProvider trending) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to load more. Tap to retry.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            trending.fetchMore().catchError((Object e) {
              if (e is FetchMoreException) {
                _showFetchMoreError(trending);
              }
              return null;
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showApiKeySnackbar(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('API key rejected. Update it in Settings.'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const ChangeKeyDialog(),
            );
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrendingProvider>(
      builder: (context, trending, child) {
        return CustomScrollView(
          slivers: <Widget>[
            _buildFeaturedBanner(trending),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8.0),
            ),
            _buildGrid(trending),
            if (trending.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
          controller: _scrollController,
        );
      },
    );
  }

  Widget _buildFeaturedBanner(TrendingProvider trending) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SliverList(
        key: ValueKey(trending.featuredState.runtimeType),
        delegate: SliverChildListDelegate([
          switch (trending.featuredState) {
            LoadingState() => const _FeaturedSkeleton(),
            SuccessState(data: final image) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      initQuery: 'id:${image.id}',
                    ),
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: image.urlForSize(ImageSize.medium) ??
                      fallbackImg,
                  fit: BoxFit.cover,
                  cacheManager: ImageCacheManager(),
                ),
              ),
            FailureState() => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(
                      initQuery: 'id:1',
                    ),
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: fallbackImg,
                  fit: BoxFit.cover,
                  cacheManager: ImageCacheManager(),
                ),
              ),
          },
        ]),
      ),
    );
  }

  Widget _buildGrid(TrendingProvider trending) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (trending.state) {
        LoadingState() => () {
            _apiSnackbarShown = false;
            return const SkeletonGrid();
          }(),
        SuccessState(data: final images) => () {
            _apiSnackbarShown = false;
            return _buildSuccessGrid(trending, images);
          }(),
        FailureState(message: final msg, type: final type) => () {
            if (type == FailureType.api && !_apiSnackbarShown) {
              _apiSnackbarShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _showApiKeySnackbar(context);
              });
            }
            return SliverFillRemaining(
              key: const ValueKey('error_view'),
              child: ErrorView(
                message: msg,
                onRetry: () => trending.fetchMore(refresh: true),
              ),
            );
          }(),
      },
    );
  }

  Widget _buildSuccessGrid(TrendingProvider trending, List<ImageEntity> images) {
    if (images.isEmpty) {
      return SliverFillRemaining(
        key: const ValueKey('empty_grid'),
        child: Center(
          child: Text(AppLocalizations.of(context)!.trendingEmpty),
        ),
      );
    }
    return ImageGrid(key: const ValueKey('image_grid'), model: trending);
  }
}

class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
