import 'dart:developer';

import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
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
      return results[index].smallUrl;
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
