import 'package:derpiviewer/core/data/datasources/favorites_local_source.dart';
import 'package:derpiviewer/core/data/repositories/favorites_repository_impl.dart';
import 'package:derpiviewer/core/data/repositories/image_repository_impl.dart';
import 'package:derpiviewer/core/di/injection_container.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/repositories/image_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUp(() async {
    await configureDependencies();
  });

  tearDown(() {
    // Reset get_it between test files to prevent state leakage
    GetIt.instance.reset();
  });

  group('DI Container', () {
    test('configureDependencies registers ImageRepository', () async {
      final repo = GetIt.instance<ImageRepository>();
      expect(repo, isNotNull);
      expect(repo, isA<ImageRepository>());
      expect(repo, isA<ImageRepositoryImpl>());
    });

    test('configureDependencies registers FavoritesRepository', () async {
      final repo = GetIt.instance<FavoritesRepository>();
      expect(repo, isNotNull);
      expect(repo, isA<FavoritesRepository>());
      expect(repo, isA<FavoritesRepositoryImpl>());
    });

    test('configureDependencies registers FavoritesLocalSource', () async {
      final source = GetIt.instance<FavoritesLocalSource>();
      expect(source, isNotNull);
      expect(source, isA<FavoritesLocalSource>());
    });

    test('all registrations resolve without exceptions', () async {
      // Should not throw
      GetIt.instance<ImageRepository>();
      GetIt.instance<FavoritesRepository>();
      GetIt.instance<FavoritesLocalSource>();
    });

    test('unregistered type throws on resolve', () {
      // get_it throws StateError when type is not registered
      expect(
        () => GetIt.instance<String>(),
        throwsA(isA<StateError>()),
      );
    });

    test('resolve<T>() helper works', () async {
      final repo = resolve<ImageRepository>();
      expect(repo, isNotNull);
      expect(repo, isA<ImageRepositoryImpl>());
    });

    test('registerLazySingleton returns identical instance', () async {
      final a = GetIt.instance<ImageRepository>();
      final b = GetIt.instance<ImageRepository>();
      expect(identical(a, b), isTrue);
    });
  });
}
