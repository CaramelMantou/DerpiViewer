import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/helpers/philomena_api.dart';
import 'package:derpiviewer/models/pref_model.dart';

class TrendingModel extends SearchInterface {
  List<ImageResponse> trendings = <ImageResponse>[];
  ImageResponse? featured;
  late PrefModel prefModel;
  int page = 1;
  int imageCount = 0;
  bool over = false;
  bool _isLocked = false;
  TrendingModel(PrefModel model) {
    prefModel = model;
    // fetchMore(refresh: true);
  }
  Future fetchTrending(Booru booru, PrefParams params,
      {String? key, bool refresh = false}) async {
    if (_isLocked) {
      return;
    }
    try {
      log("Start loading");
      _isLocked = true;
      if (over) return;
      page = refresh ? 1 : page + 1;
      List<ImageResponse> more = await fetchImages(
          booru: booru,
          query: prefModel.featuredQuery,
          filterID: params.filterID,
          page: page,
          perPage: params.perPage,
          sortDirection: ConstStrings.sds[SortDirection.desc.index],
          sortField: ConstStrings.sfs[SortField.wilsonScore.index]);
      if (more.isEmpty) {
        over = true;
        return;
      }
      if (refresh) {
        featured = await fetchFeaturedImage(booru: booru);
        trendings = <ImageResponse>[];
      } else {
        featured ??= await fetchFeaturedImage(booru: booru);
      }
      trendings.addAll(more);
      imageCount = trendings.length;
      notifyListeners();
    } finally {
      _isLocked = false;
    }
  }

  @override
  String getItemUrl(int index, Size size) {
    switch (size) {
      case Size.full:
        return trendings[index].fullUrl;
      case Size.large:
        return trendings[index].largeUrl;
      case Size.medium:
        return trendings[index].mediumUrl;
      case Size.small:
        return trendings[index].smallUrl;
      case Size.thumb:
        return trendings[index].thumbUrl;
      case Size.thumbSmall:
        return trendings[index].thumbSmallUrl;
      case Size.thumbTiny:
        return trendings[index].thumbTinyUrl;
      default:
        return "";
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
    return trendings[index];
  }

  @override
  ContentFormat getItemFormat(int index) {
    return trendings[index].format;
  }

  @override
  int getItemID(int index) {
    return trendings[index].id;
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
