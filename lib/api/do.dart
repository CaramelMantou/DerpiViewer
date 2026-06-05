import 'dart:convert';

import 'package:derpiviewer/config/constants.dart';
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
  ImageResponse.fromEntity(
      {required int id,
      required Booru booru,
      required String fullUrl,
      required String smallUrl,
      required String mediumUrl,
      required String largeUrl,
      required String thumbUrl,
      required String thumbSmallUrl,
      required String thumbTinyUrl,
      required ContentFormat format,
      required List<String> tags,
      required List<int> tagids,
      required String description,
      required String createdAt,
      required double duration,
      required int upvotes,
      required int downvotes,
      required int comments,
      required int faves,
      required String uploader,
      required List<String> sourceUrls}) {
    this.id = id;
    this.booru = booru;
    this.fullUrl = fullUrl;
    this.smallUrl = smallUrl;
    this.mediumUrl = mediumUrl;
    this.largeUrl = largeUrl;
    this.thumbUrl = thumbUrl;
    this.thumbSmallUrl = thumbSmallUrl;
    this.thumbTinyUrl = thumbTinyUrl;
    this.format = format;
    this.tags = tags;
    this.tagids = tagids;
    this.description = description;
    this.createdAt = createdAt;
    this.duration = duration;
    this.upvotes = upvotes;
    this.downvotes = downvotes;
    this.comments = comments;
    this.faves = faves;
    this.uploader = uploader;
    this.sourceUrls = sourceUrls;
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
    format = ContentFormat.values[formatExtensions.indexOf(obj["format"])];
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
        "format": formatExtensions[format.index],
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
