import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClearCacheDialog extends StatelessWidget {
  const ClearCacheDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('清除缓存'),
      children: [
        ListTile(
          title: const Text('清除图片缓存'),
          leading: const Icon(Icons.image),
          onTap: () async {
            await ImageCacheManager().emptyCache();
            Fluttertoast.showToast(msg: '图片缓存已清除');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('清除视频缓存'),
          leading: const Icon(Icons.video_library),
          onTap: () async {
            await VideoCacheManager().emptyCache();
            Fluttertoast.showToast(msg: '视频缓存已清除');
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('清除所有缓存'),
          leading: const Icon(Icons.delete),
          onTap: () async {
            ImageCacheManager().emptyCache();
            await VideoCacheManager().emptyCache();
            Fluttertoast.showToast(msg: '所有缓存已清除');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
