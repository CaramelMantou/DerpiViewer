import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/models/pref_model.dart';

/// Pure abstract interface for search functionality.
///
/// Lives in the domain layer — NO Flutter imports, NO `extends ChangeNotifier`.
/// Providers implement this interface on top of their own ChangeNotifier extension.
abstract class SearchInterface {
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
