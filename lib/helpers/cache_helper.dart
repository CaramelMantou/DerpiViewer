import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager extends CacheManager {
  static const key = 'imageCache';

  ImageCacheManager()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 200,
        ));
}

class VideoCacheManager extends CacheManager {
  static const key = 'videoCache';

  VideoCacheManager()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 50,
        ));
}
