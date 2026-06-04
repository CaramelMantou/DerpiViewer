import 'package:get_it/get_it.dart';

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
/// Placeholder registrations are commented out — they will be wired
/// in Stories 1.2 and 1.3 as repository implementations and API
/// strategies are introduced.
Future<void> configureDependencies() async {
  // Repository implementations — registered in later stories.
  // _getIt.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl(...));
  // _getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(...));

  // ApiStrategy instances — registered in later stories.

  // Dio instances — registered in later stories.
}
