import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';
import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangeBooruDialog extends StatelessWidget {
  final PrefModel pref;
  const ChangeBooruDialog({super.key, required this.pref});
  @override
  Widget build(BuildContext context) {
    Map<Booru, String> boorus = ConstStrings.boorus;
    int booruNum = boorus.length;
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.drawerBooruTitle),
      children: <Widget>[
        for (var i = 0; i < booruNum; i++)
          generateOption(boorus[Booru.values[i]] ?? "", context, i)
      ],
    );
  }

  Widget generateOption(String text, BuildContext context, int idx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleDialogOption(
          onPressed: () {
            pref.changeHost(Booru.values[idx]);
            Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                msg: AppLocalizations.of(context)!
                    .drawerBooruSwitchMessage(text));
            Navigator.pop(context, null);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const Divider(), // 添加分割线
      ],
    );
  }
}

class ChangeParamDialog extends StatelessWidget {
  const ChangeParamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      Map<String, int> curFilters = ConstStrings.filters[pref.booru]!;
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawerSearchTitle),
        children: [
          // 排序方向下拉菜单
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<SortDirection>(
              leadingIcon: const Icon(Icons.sort),
              width: MediaQuery.of(context).size.width * 0.7,
              label:
                  Text(AppLocalizations.of(context)!.drawerSearchSortDirection),
              initialSelection: pref.params.sortDirection,
              onSelected: (value) {
                if (value != null) {
                  pref.updateParams(sd: value);
                }
              },
              dropdownMenuEntries: [
                for (SortDirection i in SortDirection.values)
                  DropdownMenuEntry<SortDirection>(
                    value: i,
                    label: ConstStrings.getSds(context, i),
                  )
              ],
            ),
          ),

          // 排序字段下拉菜单
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<SortField>(
              leadingIcon: const Icon(Icons.filter_list),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSearchSortField),
              initialSelection: pref.params.sortField,
              onSelected: (value) {
                if (value != null) {
                  pref.updateParams(sf: value);
                  Navigator.pop(context, null);
                }
              },
              dropdownMenuEntries: [
                for (SortField i in SortField.values)
                  DropdownMenuEntry<SortField>(
                    value: i,
                    label: ConstStrings.getSfs(context, i),
                  )
              ],
            ),
          ),

          // 过滤器下拉菜单
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<String>(
              leadingIcon: const Icon(Icons.filter_alt),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSearchFilter),
              initialSelection: pref.params.filterName,
              onSelected: (value) {
                if (value != null) {
                  pref.updateParams(fid: curFilters[value], fn: value);
                  Navigator.pop(context, null);
                }
              },
              dropdownMenuEntries: [
                for (String s in curFilters.keys)
                  DropdownMenuEntry<String>(
                    value: s,
                    label: s,
                  )
              ],
            ),
          ),
        ],
      );
    }));
  }
}

class ChangeDownloadPrefDialog extends StatelessWidget {
  const ChangeDownloadPrefDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawerSizeTitle),
        children: [
          // 图片预览大小
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
          // 视频预览大小
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
          // 下载大小
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
          // 分享大小
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

class ChangeKeyDialog extends StatelessWidget {
  const ChangeKeyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      TextEditingController textController =
          TextEditingController(text: pref.key);
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawerApiTitle),
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: textController,
                  onSubmitted: ((value) {
                    pref.updateKey(value);
                  }),
                  //Header
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "API Key",
                      icon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textController.clear();
                          })))),
          Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Text(
                AppLocalizations.of(context)!.drawerApiHint,
                style: const TextStyle(fontSize: 12),
              )),
          const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: SelectableText(
                "https://derpibooru.org/registrations/edit",
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ))
        ],
      );
    }));
  }
}

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

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineSmall: const TextStyle(
                color: Colors.blue, // 设置 applicationName 的字体颜色
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      child: AboutDialog(
        applicationName: 'DerpiViewer',
        applicationVersion: '1.0.0',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Author:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('CaramelMantou@github'),
                const SizedBox(height: 8),
                const Text('Github Repository:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(
                  'https://github.com/CaramelMantou/derpiviewer',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    launchUrl(Uri.parse(
                        'https://github.com/CaramelMantou/derpiviewer'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChangeSlideIntervalDialog extends StatelessWidget {
  final PrefModel pref;
  const ChangeSlideIntervalDialog({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置幻灯片间隔'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('当前间隔: ${pref.slideInterval}秒'),
          Slider(
            value: pref.slideInterval.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '${pref.slideInterval}秒',
            onChanged: (value) {
              pref.setSlideInterval(value.round());
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
