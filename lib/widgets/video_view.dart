import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/ui/widgets/error_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class VideoView extends StatefulWidget {
  final String src;
  final VoidCallback? onRetry;
  const VideoView({super.key, required this.src, this.onRetry});
  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late String _src;
  late VideoCacheManager _cacheManager;
  VideoPlayerController? _videoPlayerController;
  ChewieController? chewieController;
  bool _hasError = false;
  bool _isInitializing = false;

  @override
  void initState() {
    _src = widget.src;
    _cacheManager = VideoCacheManager();
    _initializeVideoPlayer();
    super.initState();
  }

  Future<void> _initializeVideoPlayer() async {
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      final file = await _cacheManager.getSingleFile(_src);
      _videoPlayerController = VideoPlayerController.file(file);

      await _videoPlayerController!.initialize();
      if (!mounted) {
        _isInitializing = false;
        return;
      }

      chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
      );
      setState(() {
        _hasError = false;
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) {
        _isInitializing = false;
        return;
      }
      debugPrint('视频初始化失败: $e');
      // Dispose any partially-initialized controllers before nullifying
      chewieController?.dispose();
      _videoPlayerController?.dispose();
      setState(() {
        _hasError = true;
        _videoPlayerController = null;
        chewieController = null;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded = chewieController != null;
    final isError = _hasError && !isLoaded;

    if (isError) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ErrorView(
          key: const ValueKey('video_error'),
          message: 'Failed to load video',
          onRetry: () {
            if (_isInitializing) return;
            widget.onRetry?.call();
            setState(() {
              _hasError = false;
            });
            _initializeVideoPlayer();
          },
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoaded
          ? Center(
              key: const ValueKey('video_loaded'),
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(
                  controller: chewieController!,
                ),
              ),
            )
          : const Center(
              key: ValueKey('video_loading'),
              child: CircularProgressIndicator.adaptive(),
            ),
    );
  }

  @override
  void dispose() {
    chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
