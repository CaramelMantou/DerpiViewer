import 'dart:async';
import 'dart:developer';

import 'package:derpiviewer/api/clients.dart';
import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:synchronized/synchronized.dart';

class TrendingModel extends SearchModel {
  ImageResponse? featured;
  final Lock _fetchLock = Lock();

  TrendingModel(PrefModel model) : super(model) {
    // fetchMore(refresh: true);
  }

  @override
  Future fetchMore({bool refresh = false}) async {
    log("fetchMore");
    if (over || (!refresh && _fetchLock.locked)) return;

    await _fetchLock.synchronized(() async {
      try {
        log("Start loading");
        page = refresh ? 1 : page + 1;

        List<ImageResponse> more = await BasePhilomenaClient().fetchImages(
            booru: prefModel.booru,
            query: prefModel.featuredQuery,
            filterID: prefModel.params.filterID,
            page: page,
            perPage: prefModel.params.perPage,
            sortDirection: ConstStrings.sds[SortDirection.desc.index],
            sortField: ConstStrings.sfs[prefModel.params.sortField.index]);

        if (more.isEmpty) {
          over = true;
          return;
        }

        if (refresh) {
          featured = await BasePhilomenaClient()
              .fetchFeaturedImage(booru: prefModel.booru);
          results = <ImageResponse>[];
        } else {
          featured ??= await BasePhilomenaClient()
              .fetchFeaturedImage(booru: prefModel.booru);
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
}
