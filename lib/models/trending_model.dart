import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/api/clients.dart';
import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:synchronized/synchronized.dart';

class TrendingModel extends SearchInterface {
  List<ImageResponse> results = <ImageResponse>[];
  ImageResponse? featured;
  late PrefModel prefModel;
  int page = 1;
  int imageCount = 0;
  bool over = false;
  final Lock _fetchLock = Lock(); // 添加Lock对象

  TrendingModel(PrefModel model) {
    prefModel = model;
    // fetchMore(refresh: true);
  }
  Future fetchTrending(Booru booru, PrefParams params,
      {String? key, bool refresh = false}) async {
    if (over || (!refresh && _fetchLock.locked)) return;
    await _fetchLock.synchronized(() async {
      try {
        log("Start loading");
        page = refresh ? 1 : page + 1;

        List<ImageResponse> more = await BasePhilomenaClient().fetchImages(
            booru: booru,
            query: prefModel.featuredQuery,
            filterID: params.filterID,
            page: page,
            perPage: params.perPage,
            sortDirection: ConstStrings.sds[SortDirection.desc.index],
            sortField: ConstStrings.sfs[params.sortField.index]);

        if (more.isEmpty) {
          over = true;
          return;
        }

        if (refresh) {
          featured =
              await BasePhilomenaClient().fetchFeaturedImage(booru: booru);
          results = <ImageResponse>[];
        } else {
          featured ??=
              await BasePhilomenaClient().fetchFeaturedImage(booru: booru);
        }

        results.addAll(more);
        imageCount = results.length;
        notifyListeners();
      } catch (e) {
        log('Fail loading trendings: $e');
        rethrow;
      }
    });
  }

  @override
  String getItemUrl(int index, Size size) {
    switch (size) {
      case Size.full:
        return results[index].fullUrl;
      case Size.large:
        return results[index].largeUrl;
      case Size.medium:
        return results[index].mediumUrl;
      case Size.small:
        return results[index].smallUrl;
      case Size.thumb:
        return results[index].thumbUrl;
      case Size.thumbSmall:
        return results[index].thumbSmallUrl;
      case Size.thumbTiny:
        return results[index].thumbTinyUrl;
    }
  }

  @override
  int getItemCount() {
    return imageCount;
  }

  @override
  void fetchMore({bool refresh = false}) {
    log("fetchMore");
    fetchTrending(prefModel.booru, prefModel.params,
        key: prefModel.key, refresh: refresh);
  }

  @override
  ImageResponse getItem(int index) {
    return results[index];
  }

  @override
  ContentFormat getItemFormat(int index) {
    return results[index].format;
  }

  @override
  int getItemID(int index) {
    return results[index].id;
  }

  @override
  Booru getBooru() {
    return prefModel.booru;
  }

  @override
  PrefModel getPref() {
    return prefModel;
  }

  @override
  String getItemMediumThumbUrl(int index) {
    if (results[index].format == ContentFormat.mp4 ||
        results[index].format == ContentFormat.webm) {
      return results[index].thumbUrl;
    } else {
      return results[index].mediumUrl;
    }
  }

  @override
  String getItemThumbUrl(int index) {
    if (results[index].format == ContentFormat.mp4 ||
        results[index].format == ContentFormat.webm) {
      return results[index].thumbUrl;
    } else {
      return results[index].smallUrl;
    }
  }
}
