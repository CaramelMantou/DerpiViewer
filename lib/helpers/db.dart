import 'dart:developer';
import 'dart:io';

import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  static late Directory tempdir;
  static late Database database;
  static Future initDB() async {
    // log(temppath);
    Directory tempdir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    if (!tempdir.existsSync()) {
      await tempdir.create(recursive: true);
    }
    String databasePath = '${tempdir.path}/dv.db';
    database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS favourites (
            id INTEGER,
            booru INTEGER,
            full VARCHAR(64),
            small VARCHAR(64),
            medium VARCHAR(64),
            large VARCHAR(64),
            thumb VARCHAR(64),
            thumbsmall VARCHAR(64),
            thumbtiny VARCHAR(64),
            format VARCHAR(32),
            tags TEXT,
            tagids TEXT,
            description TEXT,
            createdat VARCHAR(64),
            duration DOUBLE,
            upvotes INTEGER,
            downvotes INTEGER,
            comments INTEGER,
            faves INTEGER,
            uploader VARCHAR(64),
            sources TEXT
          )
        ''');
      },
    );
    // Create favorite_tags unconditionally — handles both fresh installs
    // (onCreate above) and existing v1 upgrades (onCreate never re-fires).
    await database.execute('''
      CREATE TABLE IF NOT EXISTS favorite_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag VARCHAR(256) UNIQUE NOT NULL
      )
    ''');
  }

  static Future<List<ImageResponse>> getFavorites(
      Booru booru, int page, int perpage) async {
    try {
      var images = await database.query("favourites",
          where: "booru = ?",
          whereArgs: [booru.index],
          limit: perpage,
          offset: (page - 1) * perpage);
      List<ImageResponse> res = images
          .map((e) => ImageResponse.fromDbQueries(e))
          .toList(growable: false);
      return res;
    } catch (e) {
      await initDB();
      return [];
    }
  }

  static Future putFavorite(
      Booru booru, ImageResponse image, bool faved) async {
    try {
      if (!faved) {
        await database.delete(
          "favourites",
          where: "id = ? and booru = ?",
          whereArgs: [image.id, booru.index],
        );
      } else {
        int id = await database.insert(
          "favourites",
          image.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        log("Favourite $id");
      }
    } catch (e) {
      await initDB();
    }
  }

  //close Database
  static Future closeDB() async {
    database.close();
  }

  //TODO: get Favorite
  static Future<bool> getFavorite(Booru booru, int itemID) async {
    try {
      var images = await database.query("favourites",
          where: "id = ? and booru = ?", whereArgs: [itemID, booru.index]);
      if (images.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      await initDB();
      return false;
    }
  }

  static Future<void> addFavoriteTag(String tag) async {
    try {
      await database.insert(
        "favorite_tags",
        {"tag": tag},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      await initDB();
    }
  }

  static Future<void> removeFavoriteTag(String tag) async {
    try {
      await database.delete(
        "favorite_tags",
        where: "tag = ?",
        whereArgs: [tag],
      );
    } catch (e) {
      await initDB();
    }
  }

  static Future<List<String>> getAllFavoriteTags() async {
    try {
      final rows = await database.query("favorite_tags", columns: ["tag"]);
      return rows.map((row) => row["tag"] as String).toList(growable: false);
    } catch (e) {
      await initDB();
      return [];
    }
  }

  static Future<bool> isFavoriteTag(String tag) async {
    try {
      final rows = await database.query(
        "favorite_tags",
        where: "tag = ?",
        whereArgs: [tag],
      );
      return rows.isNotEmpty;
    } catch (e) {
      await initDB();
      return false;
    }
  }
}
