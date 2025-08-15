import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/helpers/connect.dart';

class BasePhilomenaClient {
  // 单例实例
  static final BasePhilomenaClient _instance = BasePhilomenaClient._internal();

  // 工厂构造函数返回单例
  factory BasePhilomenaClient() => _instance;

  // 私有构造函数
  BasePhilomenaClient._internal();

  Future<ImageResponse> fetchImage(
      {required Booru booru, required int id, String? key}) async {
    Map<String, dynamic> params = {"key": key ?? ""};
    var data = await getData(
        booru: ConstStrings.boorus[booru] ?? ConstStrings.defaultHost,
        path: "/api/v1/json/images/$id",
        params: params);
    return ImageResponse.fromJson(data["image"], booru);
  }

  Future<ImageResponse> fetchFeaturedImage(
      {required Booru booru, String? key}) async {
    Map<String, dynamic> params = {"key": key ?? ""};
    var data = await getData(
        booru: ConstStrings.boorus[booru] ?? ConstStrings.defaultHost,
        path: ConstStrings.trendingPaths[booru] ?? ConstStrings.defaultTP,
        params: params);
    late Map<String, dynamic> image;
    if (booru == Booru.twi) {
      image = data["post"];
    } else {
      image = data["image"];
    }
    return ImageResponse.fromJson(image, booru);
  }

  Future<List<ImageResponse>> fetchImages(
      {required Booru booru,
      required String query,
      String? key,
      int? filterID,
      int? page,
      int? perPage,
      String? sortDirection,
      String? sortField}) async {
    Map<String, dynamic> params = {
      "q": query,
      "key": key ?? "",
      "filter_id": "${filterID ?? ''}",
      "page": "${page ?? ''}",
      "per_page": "${perPage ?? ''}",
      "sd": sortDirection ?? "",
      "sf": sortField ?? ""
    };
    var data = await getData(
        booru: ConstStrings.boorus[booru] ?? ConstStrings.defaultHost,
        path: ConstStrings.searchPaths[booru] ?? ConstStrings.defaultTP,
        params: params);
    if (data.isEmpty) return [];
    late List<dynamic> images;
    if (booru == Booru.twi) {
      images = data["posts"];
    } else {
      images = data["images"];
    }
    List<ImageResponse> res = images
        .map((e) => ImageResponse.fromJson(e, booru))
        .toList(growable: false);
    return res;
  }
}
