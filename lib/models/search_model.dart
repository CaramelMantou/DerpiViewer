import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/widgets.dart';

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
