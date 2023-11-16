import 'dart:developer';

import 'package:derpiviewer/enums.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class DownloadHelper {
  static const _channel = MethodChannel('com.caramelmantou.derpiviewer/path');
  static String? downloadpath;
  static String? temppath;
  static Future getDownloadPath() async {
    downloadpath ??= await _channel.invokeMethod('getPictures');
  }

  static Future getTempPath() async {
    temppath ??= await _channel.invokeMethod('getTemp');
    // log(temppath);
    Directory tempdir = Directory(temppath!);
    if (!tempdir.existsSync()) {
      await tempdir.create(recursive: true);
    }
  }

  static Future checkPath() async {
    Directory derpidir = Directory("$downloadpath/DerpiViewer");
    if (!derpidir.existsSync()) {
      await Directory("$downloadpath/DerpiViewer/Derpibooru")
          .create(recursive: true);
      await Directory("$downloadpath/DerpiViewer/Ponybooru")
          .create(recursive: true);
      await Directory("$downloadpath/DerpiViewer/Twibooru")
          .create(recursive: true);
      await Directory("$downloadpath/DerpiViewer/Furbooru")
          .create(recursive: true);
      await Directory("$downloadpath/DerpiViewer/Ponerpics")
          .create(recursive: true);
      await Directory("$downloadpath/DerpiViewer/Manebooru")
          .create(recursive: true);
    }
  }

  static Future downloadFile(
      String uri, Booru booru, int id, String type) async {
    String? bs;
    await getDownloadPath();
    await checkPath();
    // final status = await Permission.storage.request();
    switch (booru) {
      case Booru.derpi:
      case Booru.trixie:
        bs = "Derpibooru";
        break;
      case Booru.pony:
        bs = "Ponybooru";
        break;
      case Booru.twi:
        bs = "Twibooru";
        break;
      case Booru.fur:
        bs = "Furbooru";
        break;
      case Booru.ponerpics:
        bs = "Ponerpics";
        break;
      case Booru.mane:
        bs = "Manebooru";
        break;
      default:
    }
    log("$downloadpath/DerpiViewer/$bs/$id.$type");
    await FlutterDownloader.enqueue(
      url: uri,
      fileName: "$id.$type",
      savedDir: "$downloadpath/DerpiViewer/$bs",
      // showNotification: true,
      // openFileFromNotification: true,
    );
    // MediaScanner.loadMedia(path: "$downloadpath/DerpiViewer/$bs/$id.$type");
  }

  static void shareLink(Booru booru, int id) {
    String? url;
    if (booru == Booru.twi) {
      url = "${ConstStrings.boorus[booru]}/$id";
    } else {
      url = "${ConstStrings.boorus[booru]}/images/$id";
    }
    Clipboard.setData(ClipboardData(text: url));
  }

  static Future shareFile(
      String uri, Booru booru, int id, ContentFormat type) async {
    await getTempPath();
    String? bs;
    switch (booru) {
      case Booru.derpi:
      case Booru.trixie:
        bs = "Derpibooru";
        break;
      case Booru.pony:
        bs = "Ponybooru";
        break;
      case Booru.twi:
        bs = "Twibooru";
        break;
      case Booru.fur:
        bs = "Furbooru";
        break;
      case Booru.ponerpics:
        bs = "Ponerpics";
        break;
      case Booru.mane:
        bs = "Manebooru";
        break;
      default:
    }
    var file = await DefaultCacheManager().getSingleFile(uri);

    // var response = await http.get(Uri.parse(uri));
    // Uint8List bytes = response.bodyBytes;

    ShareResult result = await Share.shareXFiles([
      XFile(file.path,
          name: "$bs-$id.${ConstStrings.format[type.index]}",
          mimeType: ConstStrings.mime[type.index])
    ]);
    if (result.status == ShareResultStatus.success) {
      Fluttertoast.showToast(msg: "Shared");
    }
  }
}
