import 'package:get_it/get_it.dart';
import 'package:derpiviewer/core/data/datasources/favorites_local_source.dart';
import 'package:derpiviewer/core/data/repositories/favorites_repository_impl.dart';
import 'package:derpiviewer/core/data/repositories/image_repository_impl.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/repositories/image_repository.dart';

/// Internal service locator instance.
///
/// Access is restricted to [configureDependencies] and [resolve] —
/// NEVER use directly in widgets, providers, or dialogs.
final _getIt = GetIt.instance;

/// Resolves a registered dependency of type [T].
///
/// This is the ONLY public accessor for the DI container.
/// All caller-side resolution must go through this function.
T resolve<T extends Object>() => _getIt<T>();

/// Configures the DI container with lazy singleton registrations.
///
/// Called once in [main] before [runApp].
Future<void> configureDependencies() async {
  // Data sources
  _getIt.registerLazySingleton<FavoritesLocalSource>(
    () => FavoritesLocalSource(),
  );

  // Repository implementations
  _getIt.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(),
  );
  _getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(_getIt<FavoritesLocalSource>()),
  );
}
