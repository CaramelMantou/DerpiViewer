import 'dart:developer';

import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/config/booru_config.dart';
import 'package:derpiviewer/ui/providers/favorites_provider.dart';
import 'package:derpiviewer/ui/widgets/error_view.dart';
import 'package:derpiviewer/ui/widgets/skeleton_grid.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshFavorites();
    }
  }

  void _refreshFavorites() {
    if (!mounted) return;
    final provider = context.read<FavoritesProvider>();
    provider.fetchMore(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${AppLocalizations.of(context)!.favs(1)}: ${booruHosts[provider.getBooru()] ?? ''}"),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(FavoritesProvider provider) {
    return switch (provider.state) {
      LoadingState() => const SkeletonGrid(),
      SuccessState(data: final images) when images.isEmpty => _buildEmptyState(),
      SuccessState() => const FavouriteScroll(),
      FailureState(message: final msg) => ErrorView(
          message: msg,
          onRetry: () => provider.fetchMore(refresh: true),
        ),
    };
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.favouritesEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.favouritesEmptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavouriteScroll extends StatefulWidget {
  const FavouriteScroll({super.key});
  @override
  State<FavouriteScroll> createState() => _FavouriteScrollState();
}

class _FavouriteScrollState extends State<FavouriteScroll> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(scrollCallback);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        Consumer<FavoritesProvider>(
            builder: ((context, value, child) => ImageGrid(
                  model: value,
                )))
      ],
      controller: _scrollController,
    );
  }

  void scrollCallback() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      log("loading more favorites");
      Provider.of<FavoritesProvider>(context, listen: false).fetchMore();
    }
  }
}
