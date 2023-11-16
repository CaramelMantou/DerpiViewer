import 'package:flutter/material.dart';
import 'package:derpiviewer/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:derpiviewer/helpers/philomena_api.dart';

class PrefModel extends ChangeNotifier {
  final Map<Booru, String> _boorus = ConstStrings.boorus;
  final params = PrefParams();
  String key = "";
  Booru booru = Booru.trixie;
  String featuredQuery = "first_seen_at.gt:3 days ago";
  List<String> history = <String>[];
  int historyCount = 0;
  Size videoSize = Size.medium;
  Size imageSize = Size.full;
  Size downloadSize = Size.full;
  Size shareSize = Size.full;

  PrefModel() {
    getPref();
  }
  void changeHost(Booru b) {
    booru = b;
    String fName = ConstStrings.filters[b]!.keys.first;
    updateParams(
      fn: fName,
      fid: ConstStrings.filters[b]![fName],
    );
  }

  void updateParams(
      {int? fid, int? pp, SortDirection? sd, SortField? sf, String? fn}) {
    params.filterID = fid ?? params.filterID;
    params.filterName = fn ?? params.filterName;
    params.perPage = pp ?? params.perPage;
    params.sortDirection = sd ?? params.sortDirection;
    params.sortField = sf ?? params.sortField;
    notifyListeners();
  }

  void updateKey(String k) {
    key = k;
    notifyListeners();
  }

  void getPref() async {
    final prefs = await SharedPreferences.getInstance();
    int tmpBooru = prefs.getInt("booru") ?? booru.index;
    String tmpKey = prefs.getString("key") ?? key;
    String tmpFilterName = prefs.getString("filter_name") ?? params.filterName;
    int tmpPerPage = prefs.getInt("per_page") ?? params.perPage;
    int tmpSD = prefs.getInt("sd") ?? params.sortDirection.index;
    int tmpSF = prefs.getInt("sf") ?? params.sortField.index;
    int tmpImageSize = prefs.getInt("image_size") ?? imageSize.index;
    int tmpVideoSize = prefs.getInt("video_size") ?? imageSize.index;
    int tmpDownloadSize = prefs.getInt("download_size") ?? imageSize.index;
    int tmpShareSize = prefs.getInt("share_size") ?? imageSize.index;
    booru = Booru.values[tmpBooru];
    imageSize = Size.values[tmpImageSize];
    videoSize = Size.values[tmpVideoSize];
    downloadSize = Size.values[tmpDownloadSize];
    shareSize = Size.values[tmpShareSize];
    key = tmpKey;
    if (!ConstStrings.filters[booru]!.containsKey(tmpFilterName)) {
      tmpFilterName = ConstStrings.filters[booru]!.keys.first;
    }
    updateParams(
        fn: tmpFilterName,
        fid: ConstStrings.filters[booru]![tmpFilterName],
        pp: tmpPerPage,
        sd: SortDirection.values[tmpSD],
        sf: SortField.values[tmpSF]);
  }

  Future savePref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("booru", booru.index);
    await prefs.setString("key", key);
    await prefs.setString("filter_name", params.filterName);
    await prefs.setInt("per_page", params.perPage);
    await prefs.setInt("sd", params.sortDirection.index);
    await prefs.setInt("sf", params.sortField.index);
    await prefs.setInt("image_size", imageSize.index);
    await prefs.setInt("video_size", videoSize.index);
    await prefs.setInt("download_size", downloadSize.index);
    await prefs.setInt("share_size", shareSize.index);
  }
}
