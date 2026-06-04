import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:derpiviewer/config/booru_config.dart';
import 'package:derpiviewer/helpers/db.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/pages/fav_page.dart';
import 'package:derpiviewer/pages/search_page.dart';
import 'package:derpiviewer/ui/providers/connectivity_provider.dart';
import 'package:derpiviewer/ui/providers/favorites_provider.dart';
import 'package:derpiviewer/ui/widgets/home_drawer.dart';
import 'package:derpiviewer/ui/widgets/trending_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final ReceivePort _port = ReceivePort();
  String _downloadMsg = 'Download complete';
  bool _bannerShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _downloadMsg = AppLocalizations.of(context)!.downloadComplete;
  }

  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];
      if (status == DownloadTaskStatus.complete) {
        Fluttertoast.showToast(msg: _downloadMsg);
      }
      log("$progress");
    });
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await Provider.of<PrefModel>(context, listen: false).savePref();
          DbHelper.closeDB();
          return true;
        },
        child: Consumer<ConnectivityProvider>(
          builder: (context, connectivity, child) {
            // Show/hide MaterialBanner via ScaffoldMessenger for proper
            // slide animation and dismiss support.
            if (!connectivity.isOnline && !_bannerShown) {
              _bannerShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(
                      content: const Text(
                          "You're offline — showing cached content."),
                      leading:
                          const Icon(Icons.wifi_off, color: Colors.white),
                      backgroundColor: Colors.grey[800]!,
                      actions: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .hideCurrentMaterialBanner();
                            _bannerShown = false;
                          },
                          child: const Text('DISMISS',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
              });
            } else if (connectivity.isOnline && _bannerShown) {
              _bannerShown = false;
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            }
            return Scaffold(
              appBar: AppBar(
                  title: Text(
                      "Derpiviewer (${booruHosts[Provider.of<PrefModel>(context).booru] ?? ""})")),
              body: const TrendingScroll(),
              drawer: const HomeDrawer(),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      Provider.of<FavoritesProvider>(context, listen: false)
                          .changeFav();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FavouritePage()));
                    },
                    heroTag: "fav-fab",
                    tooltip: AppLocalizations.of(context)!.tooltipFavorites,
                    child: Semantics(
                      label: AppLocalizations.of(context)!.tooltipFavorites,
                      child: const Icon(Icons.favorite),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: connectivity.isOnline
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SearchPage()));
                          }
                        : null,
                    heroTag: "sch-fab",
                    tooltip: AppLocalizations.of(context)!.tooltipSearch,
                    child: Semantics(
                      label: AppLocalizations.of(context)!.tooltipSearch,
                      child: const Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
