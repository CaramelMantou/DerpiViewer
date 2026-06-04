import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/helpers/db.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/pages/fav_page.dart';
import 'package:derpiviewer/pages/search_page.dart';
import 'package:derpiviewer/ui/providers/trending_provider.dart';
import 'package:derpiviewer/ui/widgets/error_view.dart';
import 'package:derpiviewer/ui/widgets/skeleton_grid.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import "package:flutter/material.dart";
import "package:derpiviewer/widgets/dialogs.dart";
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';

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
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
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
    _scrollController.addListener(_scrollCallback);
    // Trigger initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<TrendingProvider>(context, listen: false)
          .fetchMore(refresh: true)
          .catchError((Object e) {
        log('Initial trending fetch failed', error: e);
        return null;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollCallback);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollCallback() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0) {
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final trending = Provider.of<TrendingProvider>(context, listen: false);
      trending.fetchMore().catchError((Object e) {
        if (e is FetchMoreException) {
          _showFetchMoreError(trending);
        }
        return null;
      });
    }
  }

  void _showFetchMoreError(TrendingProvider trending) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to load more. Tap to retry.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            trending.fetchMore().catchError((Object e) {
              if (e is FetchMoreException) {
                _showFetchMoreError(trending);
              }
              return null;
            });
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrendingProvider>(
      builder: (context, trending, child) {
        return CustomScrollView(
          slivers: <Widget>[
            // Featured image banner
            _buildFeaturedBanner(trending),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8.0),
            ),
            // Trending image grid
            _buildGrid(trending),
            // Tail loading indicator
            if (trending.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
          controller: _scrollController,
        );
      },
    );
  }

  Widget _buildFeaturedBanner(TrendingProvider trending) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SliverList(
        key: ValueKey(trending.featuredState.runtimeType),
        delegate: SliverChildListDelegate([
          switch (trending.featuredState) {
            LoadingState() => const _FeaturedSkeleton(),
            SuccessState(data: final image) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      initQuery: 'id:${image.id}',
                    ),
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: image.urlForSize(ImageSize.medium) ??
                      ConstStrings.fallbackImg,
                  fit: BoxFit.cover,
                  cacheManager: ImageCacheManager(),
                ),
              ),
            FailureState() => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(
                      initQuery: 'id:1',
                    ),
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: ConstStrings.fallbackImg,
                  fit: BoxFit.cover,
                  cacheManager: ImageCacheManager(),
                ),
              ),
          },
        ]),
      ),
    );
  }

  Widget _buildGrid(TrendingProvider trending) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (trending.state) {
        LoadingState() => const SkeletonGrid(),
        SuccessState(data: final images) =>
          _buildSuccessGrid(trending, images),
        FailureState(message: final msg) => SliverFillRemaining(
            key: const ValueKey('error_view'),
            child: ErrorView(
              message: msg,
              onRetry: () => trending.fetchMore(refresh: true),
            ),
          ),
      },
    );
  }

  Widget _buildSuccessGrid(TrendingProvider trending, List<ImageEntity> images) {
    if (images.isEmpty) {
      return const SliverFillRemaining(
        key: ValueKey('empty_grid'),
        child: Center(
          child: Text('No trending images available'),
        ),
      );
    }
    return ImageGrid(key: const ValueKey('image_grid'), model: trending);
  }
}

/// Skeleton placeholder for the featured image banner.
class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
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
                    "${AppLocalizations.of(context)!.drawerBooruDescription} ${ConstStrings.boorus[pref.booru]}",
                    // style:
                    //     const TextStyle(fontSize: 12.0, color: Colors.white)
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
        // ListTile(
        //     title: Text(AppLocalizations.of(context)!.drawerApiTitle),
        //     subtitle: Text(AppLocalizations.of(context)!.drawerApiDescription,
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
          title: const Text('清除缓存'),
          subtitle: const Text('清除图片和视频缓存', style: TextStyle(fontSize: 12.0)),
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
          title: const Text('关于'),
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
          title: const Text('单列模式'),
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
          title: const Text('幻灯片间隔'),
          leading: const Icon(Icons.slideshow),
          subtitle: Consumer<PrefModel>(
            builder: (context, pref, child) => Text('${pref.slideInterval}秒'),
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
                    '夜间模式',
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
