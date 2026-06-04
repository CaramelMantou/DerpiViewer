import 'package:derpiviewer/config/tag_categories.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void appendClipboard(String local, String text) async {
  Clipboard.setData(ClipboardData(text: text));
  Fluttertoast.showToast(msg: "$local \"$text\"");
}

TagCategory getTagCategory(String tag, int tagid, Booru booru) {
  if (ratingTags.contains(tag)) return TagCategory.rating;
  if (bodyTags.contains(tag)) return TagCategory.body;
  if (errorTags.contains(tag)) return TagCategory.error;
  if (tag.contains("spoiler:")) return TagCategory.spoiler;
  if (tag.contains("artist:")) return TagCategory.artist;
  if (tag.contains("oc:")) return TagCategory.oc;
  return TagCategory.general;
}
