import 'dart:convert';

import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';

class ImageResponse {
  late int id;
  late Booru booru;
  late String fullUrl;
  late String smallUrl;
  late String mediumUrl;
  late String largeUrl;
  late String thumbUrl;
  late String thumbSmallUrl;
  late String thumbTinyUrl;
  late ContentFormat format;
  late List<String> tags;
  late List<int> tagids;
  late String description;
  late String createdAt;
  late double duration;
  late int upvotes;
  late int downvotes;
  late int comments;
  late int faves;
  late String uploader;
  late List<String> sourceUrls;

  ImageResponse(
      this.id,
      this.booru,
      this.fullUrl,
      this.smallUrl,
      this.mediumUrl,
      this.largeUrl,
      this.thumbUrl,
      this.thumbSmallUrl,
      this.thumbTinyUrl,
      this.tags,
      this.tagids,
      this.format,
      this.description,
      this.createdAt,
      this.duration,
      this.upvotes,
      this.downvotes,
      this.comments,
      this.faves,
      this.uploader,
      this.sourceUrls);
  ImageResponse.fromJson(Map<String, dynamic> obj, Booru booru) {
    id = obj["id"];
    this.booru = booru;
    fullUrl = obj["representations"]["full"];
    smallUrl = obj["representations"]["small"];
    mediumUrl = obj["representations"]["medium"];
    largeUrl = obj["representations"]["large"];
    thumbUrl = obj["representations"]["thumb"];
    thumbSmallUrl = obj["representations"]["thumb_small"];
    thumbTinyUrl = obj["representations"]["thumb_tiny"];
    if (obj["format"] == "webm" || obj["format"] == "mp4") {
      thumbUrl = thumbUrl.replaceFirst(".webm", ".gif");
      thumbSmallUrl = thumbSmallUrl.replaceFirst(".webm", ".gif");
      thumbTinyUrl = thumbTinyUrl.replaceFirst(".webm", ".gif");
    }
    if (fullUrl[0] == "/") {
      fullUrl = "https://ponerpics.org/$fullUrl";
      smallUrl = "https://ponerpics.org/$smallUrl";
      mediumUrl = "https://ponerpics.org/$mediumUrl";
      largeUrl = "https://ponerpics.org/$largeUrl";
      thumbUrl = "https://ponerpics.org/$thumbUrl";
      thumbSmallUrl = "https://ponerpics.org/$thumbSmallUrl";
      thumbTinyUrl = "https://ponerpics.org/$thumbTinyUrl";
    }
    format = ContentFormat.values[ConstStrings.format.indexOf(obj["format"])];
    tags = List<String>.from(obj["tags"]);
    tagids = List<int>.from(obj["tag_ids"]);
    description = obj["description"];
    createdAt = obj["created_at"];
    duration = obj["duration"];
    upvotes = obj["upvotes"];
    downvotes = obj["downvotes"];
    comments = obj["comment_count"];
    faves = obj["faves"];
    uploader = obj["uploader"] ?? "";
    sourceUrls = List<String>.from(obj["source_urls"] ?? []);
  }
  ImageResponse.fromDbQueries(Map<String, dynamic> obj) {
    id = obj["id"];
    booru = Booru.values[obj["booru"]];
    fullUrl = obj["full"];
    smallUrl = obj["small"];
    mediumUrl = obj["medium"];
    largeUrl = obj["large"];
    thumbUrl = obj["thumb"];
    thumbSmallUrl = obj["thumbsmall"];
    thumbTinyUrl = obj["thumbtiny"];
    format = ContentFormat.values[ConstStrings.format.indexOf(obj["format"])];
    tags = List<String>.from(const JsonDecoder().convert(obj["tags"]));
    tagids = List<int>.from(const JsonDecoder().convert(obj["tagids"]));
    description = obj["description"];
    createdAt = obj["createdat"];
    duration = obj["duration"];
    upvotes = obj["upvotes"];
    downvotes = obj["downvotes"];
    comments = obj["comments"];
    faves = obj["faves"];
    uploader = obj["uploader"];
    sourceUrls = List<String>.from(const JsonDecoder().convert(obj["sources"]));
  }

  //to json
  Map<String, dynamic> toJson() => {
        "id": id,
        "booru": booru.index,
        "full": fullUrl,
        "small": smallUrl,
        "medium": mediumUrl,
        "large": largeUrl,
        "thumb": thumbUrl,
        "thumbsmall": thumbSmallUrl,
        "thumbtiny": thumbTinyUrl,
        "format": ConstStrings.format[format.index],
        "tags": const JsonEncoder().convert(tags),
        "tagids": const JsonEncoder().convert(tagids),
        "description": description,
        "createdat": createdAt,
        "duration": duration,
        "upvotes": upvotes,
        "downvotes": downvotes,
        "comments": comments,
        "faves": faves,
        "uploader": uploader,
        "sources": const JsonEncoder().convert(sourceUrls)
      };
}

class PrefParams {
  int filterID;
  int perPage;
  SortDirection sortDirection;
  SortField sortField;
  String filterName;
  PrefParams(
      {this.filterID = 100073,
      this.perPage = 18,
      this.sortDirection = SortDirection.desc,
      this.sortField = SortField.wilsonScore,
      this.filterName = "Default"});
}
