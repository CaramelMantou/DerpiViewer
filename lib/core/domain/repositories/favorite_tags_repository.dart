import 'package:derpiviewer/core/domain/result.dart';

/// Cross-booru persistent favorite tags repository.
///
/// Tags are plain strings shared across all boorus. This is the domain-layer
/// contract; the implementation lives in [core/data/repositories/].
abstract class FavoriteTagsRepository {
  /// Persist a tag. Duplicate adds are idempotent (no error, no duplicate row).
  Future<Result<void>> addTag(String tag);

  /// Remove a tag. Removing a non-existent tag is idempotent.
  Future<Result<void>> removeTag(String tag);

  /// Return every favorite tag. Empty list when none saved.
  Future<Result<List<String>>> getAllTags();

  /// True when [tag] is already a favorite.
  Future<Result<bool>> isFavorite(String tag);
}
