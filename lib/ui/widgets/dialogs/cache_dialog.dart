import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClearCacheDialog extends StatelessWidget {
  const ClearCacheDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SimpleDialog(
      title: Text(l10n.cacheDialogTitle),
      children: [
        ListTile(
          title: Text(l10n.cacheClearImages),
          leading: const Icon(Icons.image),
          onTap: () async {
            await ImageCacheManager().emptyCache();
            Fluttertoast.showToast(msg: l10n.cacheImagesCleared);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text(l10n.cacheClearVideos),
          leading: const Icon(Icons.video_library),
          onTap: () async {
            await VideoCacheManager().emptyCache();
            Fluttertoast.showToast(msg: l10n.cacheVideosCleared);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text(l10n.cacheClearAll),
          leading: const Icon(Icons.delete),
          onTap: () async {
            ImageCacheManager().emptyCache();
            await VideoCacheManager().emptyCache();
            Fluttertoast.showToast(msg: l10n.cacheAllCleared);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
