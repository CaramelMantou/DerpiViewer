import 'package:derpiviewer/core/data/datasources/favorites_local_source.dart';
import 'package:derpiviewer/core/data/repositories/favorites_repository_impl.dart';
import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesLocalSource extends Mock implements FavoritesLocalSource {}

void main() {
  late MockFavoritesLocalSource mockSource;
  late FavoritesRepositoryImpl repository;

  final testEntity = ImageEntity(
    id: 1,
    booru: Booru.derpi,
    urls: {ImageSize.thumb: 'https://example.com/thumb.png'},
    format: ContentFormat.png,
    tags: ['safe'],
    tagIds: [1],
    description: 'Test',
    createdAt: '2024-01-01',
    duration: 0.0,
    upvotes: 10,
    downvotes: 1,
    comments: 0,
    faves: 5,
    uploader: 'Test',
    sourceUrls: [],
  );

  setUp(() {
    mockSource = MockFavoritesLocalSource();
    repository = FavoritesRepositoryImpl(mockSource);
  });

  group('FavoritesRepositoryImpl', () {
    group('toggleFavorite', () {
      test('toggleFavorite(true) returns Failure (needs full entity)', () async {
        final result = await repository.toggleFavorite(Booru.derpi, 1, true);
        expect(result, isA<Failure<void>>());
        final failure = result as Failure<void>;
        expect(failure.message, contains('Cannot add favorite by ID alone'));
      });

      test('toggleFavorite(false) calls localSource.removeFavorite', () async {
        when(() => mockSource.removeFavorite(Booru.derpi, 1))
            .thenAnswer((_) async {});

        final result = await repository.toggleFavorite(Booru.derpi, 1, false);
        expect(result, isA<Success<void>>());
        verify(() => mockSource.removeFavorite(Booru.derpi, 1)).called(1);
      });

      test('toggleFavorite(false) on SQLite error returns Failure', () async {
        when(() => mockSource.removeFavorite(Booru.derpi, 1))
            .thenThrow(Exception('SQLite error'));

        final result = await repository.toggleFavorite(Booru.derpi, 1, false);
        expect(result, isA<Failure<void>>());
        final failure = result as Failure<void>;
        expect(failure.message, contains('Failed to toggle favorite'));
      });
    });

    group('isFavorite', () {
      test('isFavorite returns Success(true) when favorited', () async {
        when(() => mockSource.getFavorite(Booru.derpi, 1))
            .thenAnswer((_) async => true);

        final result = await repository.isFavorite(Booru.derpi, 1);
        expect(result, isA<Success<bool>>());
        final success = result as Success<bool>;
        expect(success.data, isTrue);
        verify(() => mockSource.getFavorite(Booru.derpi, 1)).called(1);
      });

      test('isFavorite returns Success(false) when not favorited', () async {
        when(() => mockSource.getFavorite(Booru.derpi, 2))
            .thenAnswer((_) async => false);

        final result = await repository.isFavorite(Booru.derpi, 2);
        expect(result, isA<Success<bool>>());
        final success = result as Success<bool>;
        expect(success.data, isFalse);
        verify(() => mockSource.getFavorite(Booru.derpi, 2)).called(1);
      });

      test('isFavorite on error returns Failure', () async {
        when(() => mockSource.getFavorite(Booru.derpi, 1))
            .thenThrow(Exception('DB error'));

        final result = await repository.isFavorite(Booru.derpi, 1);
        expect(result, isA<Failure<bool>>());
        final failure = result as Failure<bool>;
        expect(failure.message, contains('Failed to check favorite'));
        verify(() => mockSource.getFavorite(Booru.derpi, 1)).called(1);
      });
    });

    group('getFavorites', () {
      test('getFavorites returns Success with entities', () async {
        when(() => mockSource.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => [testEntity]);

        final result = await repository.getFavorites(Booru.derpi, 1, 20);
        expect(result, isA<Success<List<ImageEntity>>>());
        final success = result as Success<List<ImageEntity>>;
        expect(success.data.length, 1);
        expect(success.data[0].id, 1);
        verify(() => mockSource.getFavorites(Booru.derpi, 1, 20)).called(1);
      });

      test('getFavorites returns Success with empty list', () async {
        when(() => mockSource.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => []);

        final result = await repository.getFavorites(Booru.derpi, 1, 20);
        expect(result, isA<Success<List<ImageEntity>>>());
        final success = result as Success<List<ImageEntity>>;
        expect(success.data, isEmpty);
        verify(() => mockSource.getFavorites(Booru.derpi, 1, 20)).called(1);
      });

      test('getFavorites on error returns Failure', () async {
        when(() => mockSource.getFavorites(Booru.derpi, 1, 20))
            .thenThrow(Exception('Database error'));

        final result = await repository.getFavorites(Booru.derpi, 1, 20);
        expect(result, isA<Failure<List<ImageEntity>>>());
        final failure = result as Failure<List<ImageEntity>>;
        expect(failure.message, contains('Failed to load favorites'));
        verify(() => mockSource.getFavorites(Booru.derpi, 1, 20)).called(1);
      });
    });
  });
}
