import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeDownloadPrefDialog extends StatelessWidget {
  const ChangeDownloadPrefDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawerSizeTitle),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<ImageSize>(
              leadingIcon: const Icon(Icons.photo_library),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSizePreviewImage),
              initialSelection: pref.imageSize,
              onSelected: (value) {
                if (value != null) pref.imageSize = value;
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.full,
                  label: "Full",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.large,
                  label: "Large",
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<ImageSize>(
              leadingIcon: const Icon(Icons.video_library),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSizePreviewVideo),
              initialSelection: pref.videoSize,
              onSelected: (value) {
                if (value != null) pref.videoSize = value;
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.full,
                  label: "Full",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.large,
                  label: "Large",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.medium,
                  label: "Medium",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.small,
                  label: "Small",
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<ImageSize>(
              leadingIcon: const Icon(Icons.download),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSizeDownload),
              initialSelection: pref.downloadSize,
              onSelected: (value) {
                if (value != null) pref.downloadSize = value;
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.full,
                  label: "Full",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.large,
                  label: "Large",
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<ImageSize>(
              leadingIcon: const Icon(Icons.share),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSizeShare),
              initialSelection: pref.shareSize,
              onSelected: (value) {
                if (value != null) {
                  pref.shareSize = value;
                  Navigator.pop(context, null);
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.full,
                  label: "Full",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.large,
                  label: "Large",
                ),
                DropdownMenuEntry<ImageSize>(
                  value: ImageSize.medium,
                  label: "Medium",
                )
              ],
            ),
          ),
        ],
      );
    }));
  }
}
