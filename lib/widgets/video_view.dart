import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class VideoView extends StatefulWidget {
  final String src;
  const VideoView({super.key, required this.src});
  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late String _src;
  late VideoCacheManager _cacheManager;
  VideoPlayerController? _videoPlayerController;
  ChewieController? chewieController;
  bool _hasError = false; // 新增错误状态标志

  @override
  void initState() {
    _src = widget.src;
    _cacheManager = VideoCacheManager();
    _initializeVideoPlayer();
    super.initState();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final file = await _cacheManager.getSingleFile(_src);
      _videoPlayerController = VideoPlayerController.file(file);

      await _videoPlayerController!.initialize();
      if (!mounted) return;

      chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
      );
      setState(() {
        _hasError = false; // 重置错误状态
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('视频初始化失败: $e');
      setState(() {
        _hasError = true; // 设置错误状态
        _videoPlayerController = null;
        chewieController = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(child: Icon(Icons.error_outline, size: 50));
    }
    return chewieController != null
        ? Center(
            child: AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: Chewie(
              controller: chewieController!,
            ),
          ))
        : const Center(child: CircularProgressIndicator.adaptive());
  }

  @override
  void dispose() {
    chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
