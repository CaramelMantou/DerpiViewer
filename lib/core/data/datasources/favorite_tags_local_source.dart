import 'package:derpiviewer/helpers/db.dart';

/// Thin instance wrapper around [DbHelper] static methods for `favorite_tags`.
///
/// Exists so [FavoriteTagsRepositoryImpl] can receive it via constructor
/// injection, making the repository testable with a mock data source.
class FavoriteTagsLocalSource {
  Future<void> addTag(String tag) => DbHelper.addFavoriteTag(tag);

  Future<void> removeTag(String tag) => DbHelper.removeFavoriteTag(tag);

  Future<List<String>> getAllTags() => DbHelper.getAllFavoriteTags();

  Future<bool> isFavorite(String tag) => DbHelper.isFavoriteTag(tag);
}
