import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/helpers/philomena_api.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/widgets.dart';

class SearchModel extends SearchInterface {
  late PrefModel prefModel;

  List<ImageResponse> results = <ImageResponse>[];
  int page = 1;
  int imageCount = 0;
  bool over = false;
  bool _isLocked = false;
  String _query = "";
  SearchModel(PrefModel model) {
    prefModel = model;
  }

  Future _fetchResult({String? query, bool refresh = false}) async {
    if (_isLocked) {
      return;
    }
    try {
      log("Start loading");
      _isLocked = true;
      if (query == null && _query.isEmpty) return;
      over = query == _query;
      if (over && !refresh) return;
      PrefParams params = prefModel.params;
      _query = refresh ? query ?? _query : _query;
      page = refresh ? 1 : page + 1;
      List<ImageResponse> more = await fetchImages(
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
      _isLocked = false;
    }
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
      default:
        return "";
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
}

abstract class SearchInterface extends ChangeNotifier {
  int getItemCount();
  int getItemID(int index);
  String getItemUrl(int index, Size size);
  ImageResponse getItem(int index);
  ContentFormat getItemFormat(int index);
  void fetchMore({bool refresh});
  Booru getBooru();
  PrefModel getPref();
}
