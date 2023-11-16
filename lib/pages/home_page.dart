import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/helpers/db.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/models/trending_model.dart';
import 'package:derpiviewer/pages/fav_page.dart';
import 'package:derpiviewer/pages/search_page.dart';
// import 'package:derpiviewer/pages/search_page.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import "package:flutter/material.dart";
import "package:derpiviewer/widgets/dialogs.dart";
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/fav_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final ReceivePort _port = ReceivePort();
  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status == DownloadTaskStatus.complete) {
        Fluttertoast.showToast(msg: "Downloaded");
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

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
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
        child: Scaffold(
          appBar: AppBar(
              title: Text(
                  "Derpiviewer (${ConstStrings.boorus[Provider.of<PrefModel>(context).booru] ?? ""})")),
          body: const TrendingScroll(),
          drawer: const HomeDrawer(),
          floatingActionButton: Column(
            // crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Provider.of<FavModel>(context, listen: false).changeFav();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavouritePage()));
                },
                heroTag: "fav-fab",
                child: const Icon(Icons.favorite),
              ),
              const SizedBox(height: 10), // 适当的间距
              FloatingActionButton(
                onPressed: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()));

                  // showSearch(context: context, delegate: SearchPage());
                }),
                heroTag: "sch-fab",
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ));
  }
}

class TrendingScroll extends StatefulWidget {
  const TrendingScroll({super.key});

  @override
  State<TrendingScroll> createState() => _TrendingScrollState();
}

class _TrendingScrollState extends State<TrendingScroll> {
  late ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(scrollCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        Consumer<TrendingModel>(
            builder: (context, trending, child) => SliverList(
                    delegate: SliverChildListDelegate([
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchPage(
                                    initQuery:
                                        "id:${trending.featured?.id ?? 1}",
                                  ))),
                      child: CachedNetworkImage(
                        imageUrl: trending.featured?.mediumUrl ??
                            ConstStrings.fallbackImg,
                        fit: BoxFit.cover,
                      )),
                  const Divider(),
                ]))),
        Consumer<TrendingModel>(
            builder: ((context, value, child) => ImageGrid(
                  model: value,
                )))
      ],
      controller: _scrollController,
    );
  }

  void scrollCallback() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<TrendingModel>(context, listen: false).fetchMore();
    }
  }
}

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Colors.white),
          child: SizedBox.expand(
              child: CachedNetworkImage(
            imageUrl: "https://derpicdn.net/img/2015/9/26/988523/medium.png",
            fit: BoxFit.cover,
          )),
        ),
        Consumer<PrefModel>(
            builder: ((context, pref, child) => ListTile(
                  title: Text(AppLocalizations.of(context)!.drawer1t),
                  subtitle: Text(
                      "${AppLocalizations.of(context)!.drawer1d} ${ConstStrings.boorus[pref.booru]}",
                      style: const TextStyle(fontSize: 12.0)),
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
          title: Text(AppLocalizations.of(context)!.drawer2t),
          subtitle: Text(AppLocalizations.of(context)!.drawer2d,
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
          title: Text(AppLocalizations.of(context)!.drawer3t),
          subtitle: Text(AppLocalizations.of(context)!.drawer3d,
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
        // ListTile(
        //     title: Text(AppLocalizations.of(context)!.drawer4t),
        //     subtitle: Text(AppLocalizations.of(context)!.drawer4d,
        //         style: TextStyle(fontSize: 12.0)),
        //     leading: const Icon(Icons.key),
        //     onTap: () async {
        //       showDialog(
        //           context: context,
        //           builder: (BuildContext context) {
        //             return const ChangeKeyDialog();
        //           });
        //     }),
        ListTile(
          title: const Text('关于'),
          leading: const Icon(Icons.info),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AboutDialog(
                  applicationName: 'DerpiViewer',
                  applicationVersion: '1.0.0',
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Author: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'CaramelMantou@github',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Github Repository: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'https://github.com/CaramelMantou/derpiviewer',
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ],
    ));
  }
}
