import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/api/clients.dart';
import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

class SearchModel extends SearchInterface {
  late PrefModel prefModel;

  List<ImageResponse> results = <ImageResponse>[];
  int page = 1;
  int imageCount = 0;
  bool over = false;
  final Lock _fetchLock = Lock(); // 替换 _isLocked 的锁
  String _query = "";
  SearchModel(PrefModel model) {
    prefModel = model;
  }

  Future _fetchResult({String? query, bool refresh = false}) async {
    if (!refresh && _fetchLock.locked) {
      return;
    }
    await _fetchLock.synchronized(() async {
      try {
        log("Start loading");
        if (query == null && _query.isEmpty) return;
        bool over = query == _query;
        if (over && !refresh) return;

        PrefParams params = prefModel.params;
        _query = refresh ? query ?? _query : _query;
        page = refresh ? 1 : page + 1;

        List<ImageResponse> more = await BasePhilomenaClient().fetchImages(
            booru: prefModel.booru,
            query: query ?? _query,
            filterID: params.filterID,
            page: page,
            key: prefModel.key,
            perPage: params.perPage,
            sortDirection: ConstStrings.sds[params.sortDirection.index],
            sortField: ConstStrings.sfs[params.sortField.index]);

        if (more.isEmpty && !refresh) {
          over = true;
          return;
        } else {
          over = false;
        }

        results = refresh ? <ImageResponse>[] : results;
        results.addAll(more);
        imageCount = results.length;
        notifyListeners();
      } finally {
        // 锁会自动释放
      }
    });
  }

  void newSearch(String query) async {
    log(query);
    if (query == _query) return;
    await _fetchResult(query: query, refresh: true);
    // addHistory(query);
  }

  void addHistory(String query) {
    if (!prefModel.history.contains(query)) {
      prefModel.history.add(query);
    }
    prefModel.historyCount = prefModel.history.length;
  }

  @override
  void fetchMore({bool refresh = false}) {
    log("Fetch more");
    _fetchResult(refresh: refresh);
  }

  @override
  ImageResponse getItem(int index) {
    return results[index];
  }

  @override
  int getItemCount() {
    return imageCount;
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
  String getItemUrl(int index, ImageSize imageSize) {
    switch (imageSize) {
      case ImageSize.full:
        return results[index].fullUrl;
      case ImageSize.large:
        return results[index].largeUrl;
      case ImageSize.medium:
        return results[index].mediumUrl;
      case ImageSize.small:
        return results[index].smallUrl;
      case ImageSize.thumb:
        return results[index].thumbUrl;
      case ImageSize.thumbSmall:
        return results[index].thumbSmallUrl;
      case ImageSize.thumbTiny:
        return results[index].thumbTinyUrl;
    }
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

abstract class SearchInterface extends ChangeNotifier {
  int getItemCount();
  int getItemID(int index);
  String getItemUrl(int index, ImageSize imageSize);
  ImageResponse getItem(int index);
  ContentFormat getItemFormat(int index);
  String getItemMediumThumbUrl(int index);
  String getItemThumbUrl(int index);
  void fetchMore({bool refresh});
  Booru getBooru();
  PrefModel getPref();
}
