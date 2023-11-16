import 'dart:developer';

import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/helpers/philomena_api.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/helpers/db.dart';

class FavModel extends SearchInterface {
  late PrefModel prefModel;

  List<ImageResponse> results = <ImageResponse>[];
  int page = 1;
  int imageCount = 0;
  bool over = false;
  bool _isLocked = false;

  FavModel(PrefModel model) {
    prefModel = model;
  }

  Future _fetchResult({bool refresh = false}) async {
    if (_isLocked) {
      return;
    }
    try {
      log("Start loading");
      _isLocked = true;
      if (over && !refresh) return;
      PrefParams params = prefModel.params;
      page = refresh ? 1 : page + 1;
      List<ImageResponse> more =
          await DbHelper.getFavorites(prefModel.booru, page, params.perPage);
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

  void changeFav() {
    _fetchResult(refresh: true);
    notifyListeners();
  }

  @override
  void fetchMore({bool refresh = false}) {
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
