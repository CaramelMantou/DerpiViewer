import 'dart:developer';

import 'package:dio/dio.dart';

class DioClient {
  static dynamic _instance;
  static Dio get instance {
    _instance ??= Dio();
    return _instance;
  }
}

Future<Map<String, dynamic>> getData(
    {required String booru,
    required String path,
    Map<String, dynamic>? params}) async {
  var dio = DioClient.instance;
  Uri uri =
      Uri(scheme: "https", host: booru, path: path, queryParameters: params);
  try {
    final response = await dio.getUri(uri);
    log(uri.toString());
    if (response.statusCode == 200) {
      var data = response.data;
      return data;
    }
  } catch (e) {
    return {};
  }
  return {};
}
