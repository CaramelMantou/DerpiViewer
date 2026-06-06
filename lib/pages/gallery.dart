import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/core/domain/search_interface.dart';
import 'package:derpiviewer/widgets/toolbar.dart';
import 'package:derpiviewer/widgets/video_view.dart';
import 'package:derpiviewer/ui/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:synchronized/synchronized.dart';

class GalleryView extends StatefulWidget {
  final SearchInterface model;
  final int startIndex;
  const GalleryView({super.key, required this.model, required this.startIndex});
  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late SearchInterface _model;
  late PageController _pageController;
  late ToolbarController _toolbarController;
  late int last;
  bool isSlideshowPlaying = false;
  Timer? slideshowTimer;
  final Lock _loadLock = Lock(); // 替换_isLoadingMore的锁
  final Map<int, int> _retryCounts = {};
  int _preloadGeneration = 0;

  @override
  void initState() {
    _model = widget.model;
    _pageController = PageController(initialPage: widget.startIndex);
    _toolbarController = ToolbarController(widget.startIndex);
    last = widget.startIndex;
    _pageController.addListener(_handlePageChange);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChange);
    slideshowTimer?.cancel();
    super.dispose();
  }

  void toggleSlideshow() {
    setState(() {
      isSlideshowPlaying = !isSlideshowPlaying;
      if (isSlideshowPlaying) {
        _startSlideshow();
      } else {
        slideshowTimer?.cancel();
      }
    });
  }

  void _startSlideshow() {
    final pref = Provider.of<PrefModel>(context, listen: false);
    slideshowTimer = Timer.periodic(
      Duration(seconds: pref.slideInterval),
      (timer) {
        if (_pageController.page!.round() < _model.getItemCount() - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(0);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        body: Stack(children: [
      PhotoViewGallery.builder(
        itemCount: _model.getItemCount(),
        builder: ((context, index) {
          return PhotoViewGalleryPageOptions.customChild(
            child: () {
              if (_model.getItemFormat(index) == ContentFormat.webm) {
                return VideoView(
                  src: _model.getItemUrl(index, _model.getPref().videoSize),
                );
              } else {
                final retryKey = _retryCounts[index] ?? 0;
                return Center(
                    child: CachedNetworkImage(
                  key: ValueKey('img_${index}_$retryKey'),
                  imageUrl:
                      _model.getItemUrl(index, _model.getPref().imageSize),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                      child: CircularProgressIndicator(
                    value: progress.progress,
                  )),
                  errorWidget: (context, url, error) => ErrorView(
                    message: 'Failed to load image',
                    onRetry: () => setState(() {
                      _retryCounts[index] = retryKey + 1;
                    }),
                  ),
                  cacheManager: ImageCacheManager(),
                ));
              }
            }(),
            initialScale: PhotoViewComputedScale.contained * 1.0,
            minScale: PhotoViewComputedScale.contained * 1.0,
            maxScale: PhotoViewComputedScale.covered * 4.0,
            heroAttributes:
                PhotoViewHeroAttributes(tag: _model.getItemID(index)),
          );
        }),
        pageController: _pageController,
      ),
      GalleryToolBar(
        model: _model,
        index: _pageController.initialPage,
        controller: _toolbarController,
      ),
      // 添加幻灯片播放按钮
      Positioned(
        top: 32.0,
        right: 16.0,
        child: IconButton(
          tooltip: isSlideshowPlaying
              ? l10n.tooltipSlideshowPause
              : l10n.tooltipSlideshowPlay,
          icon: Icon(
            isSlideshowPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.grey[600],
            size: 28.0,
          ),
          onPressed: toggleSlideshow,
        ),
      ),
    ]));
  }

  void _handlePageChange() {
    var currentPageIndex = _pageController.page!.round();
    if (currentPageIndex != last) {
      last = currentPageIndex;
      log('当前页面索引: $currentPageIndex');
      _toolbarController.change(currentPageIndex);
      _preloadNextImage(currentPageIndex);
    }
    // 检查是否到达最后一张图片
    if (currentPageIndex == _model.getItemCount() - 1) {
      _loadMoreItems();
    }
  }

  Future<void> _preloadNextImage(int currentIndex) async {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= _model.getItemCount()) return;

    final gen = ++_preloadGeneration;

    try {
      final format = _model.getItemFormat(nextIndex);
      if (format == ContentFormat.webm || format == ContentFormat.mp4) return;

      final url = _model.getItemUrl(nextIndex, _model.getPref().imageSize);
      if (url.isEmpty) return;

      if (!mounted) return;
      await precacheImage(
        CachedNetworkImageProvider(url, cacheManager: ImageCacheManager()),
        context,
      );
      // Stale check — if a newer preload started while this one was in flight,
      // silently discard this result
      if (gen != _preloadGeneration) return;
    } on Exception {
      // Silent — preload failures are non-critical
    }
  }

  Future<void> _loadMoreItems() async {
    if (!_loadLock.locked) {
      await _loadLock.synchronized(() async {
        if (_pageController.page?.round() != _model.getItemCount() - 1) {
          return;
        }
        try {
          _model.fetchMore();
        } finally {
          if (mounted) {
            setState(() {});
          }
        }
      });
    } else {
      log("cannot lock");
    }
  }
}
