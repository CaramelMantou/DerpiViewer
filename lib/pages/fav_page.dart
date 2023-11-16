import 'dart:developer';

import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/models/fav_model.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${AppLocalizations.of(context)!.favs(1)}: ${ConstStrings.boorus[Provider.of<FavModel>(context).getBooru()]}"),
      ),
      body: const FavouriteScroll(),
    );
  }
}

class FavouriteScroll extends StatefulWidget {
  const FavouriteScroll({super.key});
  @override
  State<FavouriteScroll> createState() => _FavouriteScrollState();
}

class _FavouriteScrollState extends State<FavouriteScroll> {
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
        Consumer<FavModel>(
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
      log("loading more");
      Provider.of<FavModel>(context, listen: false).fetchMore();
    }
  }
}
