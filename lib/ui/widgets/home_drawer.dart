import 'package:cached_network_image/cached_network_image.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/config/booru_config.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:derpiviewer/ui/widgets/dialogs/about_dialog.dart';
import 'package:derpiviewer/ui/widgets/dialogs/booru_dialog.dart';
import 'package:derpiviewer/ui/widgets/dialogs/cache_dialog.dart';
import 'package:derpiviewer/ui/widgets/dialogs/download_prefs_dialog.dart';
import 'package:derpiviewer/ui/widgets/dialogs/search_params_dialog.dart';
import 'package:derpiviewer/ui/widgets/dialogs/slideshow_dialog.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(),
          child: SizedBox.expand(
              child: CachedNetworkImage(
            imageUrl: "https://derpicdn.net/img/2015/9/26/988523/medium.png",
            fit: BoxFit.cover,
          )),
        ),
        Consumer<PrefModel>(
            builder: ((context, pref, child) => ListTile(
                  title: Text(AppLocalizations.of(context)!.drawerBooruTitle),
                  subtitle: Text(
                    "${AppLocalizations.of(context)!.drawerBooruDescription} ${booruHosts[pref.booru] ?? ''}",
                  ),
                  leading: const Icon(Icons.image),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ChangeBooruDialog(
                            pref: pref,
                          );
                        });
                  },
                ))),
        ListTile(
          title: Text(AppLocalizations.of(context)!.drawerSearchTitle),
          subtitle: Text(AppLocalizations.of(context)!.drawerSearchDescription,
              style: const TextStyle(fontSize: 12.0)),
          leading: const Icon(Icons.settings),
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ChangeParamDialog();
                });
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.drawerSizeTitle),
          subtitle: Text(AppLocalizations.of(context)!.drawerSizeDescription,
              style: const TextStyle(fontSize: 12.0)),
          leading: const Icon(Icons.settings),
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ChangeDownloadPrefDialog();
                });
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.drawerClearCache),
          subtitle: Text(AppLocalizations.of(context)!.drawerClearCacheDescription,
              style: const TextStyle(fontSize: 12.0)),
          leading: const Icon(Icons.cached),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ClearCacheDialog();
              },
            );
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.drawerAbout),
          leading: const Icon(Icons.info),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomAboutDialog();
              },
            );
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.drawerSingleColumn),
          leading: const Icon(Icons.view_column),
          trailing: Consumer<PrefModel>(
            builder: (context, pref, child) => Switch(
              value: pref.isSingleColumn,
              onChanged: (value) => pref.toggleSingleColumn(),
            ),
          ),
          onTap: () {
            Provider.of<PrefModel>(context, listen: false).toggleSingleColumn();
          },
        ),
        // 添加幻灯片间隔设置
        ListTile(
          title: Text(AppLocalizations.of(context)!.drawerSlideshowInterval),
          leading: const Icon(Icons.slideshow),
          subtitle: Consumer<PrefModel>(
            builder: (context, pref, child) => Text(
                AppLocalizations.of(context)!.drawerSlideshowIntervalValue(pref.slideInterval)),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ChangeSlideIntervalDialog(
                  pref: Provider.of<PrefModel>(context, listen: false),
                );
              },
            );
          },
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.drawerDarkMode,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Consumer<PrefModel>(
                    builder: (context, pref, child) => Switch(
                      value: pref.isDarkMode,
                      onChanged: (value) => pref.toggleDarkMode(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
