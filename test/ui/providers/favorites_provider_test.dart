import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/ui/providers/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

/// Minimal PrefModel for testing — avoids ChangeNotifier lifecycle.
class _TestPrefModel extends PrefModel {
  _TestPrefModel() {
    booru = Booru.derpi;
    params.perPage = 20;
  }
}

final testEntity = ImageEntity(
  id: 1,
  booru: Booru.derpi,
  urls: {ImageSize.thumb: 'https://example.com/thumb.png'},
  format: ContentFormat.png,
  tags: ['safe'],
  tagIds: [1],
  description: 'Test image',
  createdAt: '2024-01-01',
  duration: 0.0,
  upvotes: 10,
  downvotes: 1,
  comments: 0,
  faves: 5,
  uploader: 'Test',
  sourceUrls: [],
);

final testEntity2 = ImageEntity(
  id: 2,
  booru: Booru.derpi,
  urls: {ImageSize.thumb: 'https://example.com/thumb2.png'},
  format: ContentFormat.jpeg,
  tags: ['artist'],
  tagIds: [2],
  description: 'Test image 2',
  createdAt: '2024-01-02',
  duration: 0.0,
  upvotes: 20,
  downvotes: 0,
  comments: 3,
  faves: 10,
  uploader: 'Test2',
  sourceUrls: [],
);

void main() {
  late MockFavoritesRepository mockRepo;
  late _TestPrefModel prefs;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockFavoritesRepository();
    prefs = _TestPrefModel();
  });

  FavoritesProvider createProvider() =>
      FavoritesProvider(mockRepo, prefs);

  group('FavoritesProvider', () {
    group('initial state', () {
      test('starts in LoadingState', () {
        final provider = createProvider();
        expect(provider.state, isA<LoadingState<List<ImageEntity>>>());
      });

      test('getItemCount returns 0 initially', () {
        final provider = createProvider();
        expect(provider.getItemCount(), 0);
      });
    });

    group('fetchMore — Success', () {
      test('transitions to SuccessState with entities', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success([testEntity, testEntity2]));

        final provider = createProvider();
        provider.fetchMore(refresh: true);

        // Wait for async
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.state, isA<SuccessState<List<ImageEntity>>>());
        final state = provider.state as SuccessState<List<ImageEntity>>;
        expect(state.data.length, 2);
        expect(provider.getItemCount(), 2);
      });

      test('transitions to SuccessState with empty list', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success([]));

        final provider = createProvider();
        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.state, isA<SuccessState<List<ImageEntity>>>());
        final state = provider.state as SuccessState<List<ImageEntity>>;
        expect(state.data, isEmpty);
        expect(provider.getItemCount(), 0);
      });
    });

    group('fetchMore — Failure', () {
      test('transitions to FailureState on error', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Failure<List<ImageEntity>>('DB error', FailureType.unknown));

        final provider = createProvider();
        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.state, isA<FailureState<List<ImageEntity>>>());
        final state = provider.state as FailureState<List<ImageEntity>>;
        expect(state.message, 'DB error');
        expect(state.type, FailureType.unknown);
      });
    });

    group('fetchMore — pagination', () {
      test('appends data on non-refresh fetchMore when hasMore is true', () async {
        // Must return exactly perPage items to keep _hasMore = true
        final manyEntities = List.generate(20, (i) => ImageEntity(
          id: i + 1, booru: Booru.derpi,
          urls: {ImageSize.thumb: 'https://example.com/$i.png'},
          format: ContentFormat.png, tags: [], tagIds: [],
          description: '', createdAt: '', duration: 0.0,
          upvotes: 0, downvotes: 0, comments: 0, faves: 0,
          uploader: '', sourceUrls: [],
        ));
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success(manyEntities));
        when(() => mockRepo.getFavorites(Booru.derpi, 2, 20))
            .thenAnswer((_) async => Success([testEntity2]));

        final provider = createProvider();
        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.getItemCount(), 20);

        provider.fetchMore(); // page 2
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.getItemCount(), 21);
      });

      test('refresh clears and reloads data', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, any<int>(), any<int>()))
            .thenAnswer((_) async => Success([testEntity]));

        final provider = createProvider();
        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getItemCount(), 1);

        final entity2 = ImageEntity(
          id: 2, booru: Booru.derpi,
          urls: {ImageSize.thumb: 'https://example.com/thumb2.png'},
          format: ContentFormat.jpeg, tags: [], tagIds: [],
          description: '', createdAt: '', duration: 0.0,
          upvotes: 0, downvotes: 0, comments: 0, faves: 0,
          uploader: '', sourceUrls: [],
        );
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success([testEntity, entity2]));

        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(provider.getItemCount(), 2);
      });
    });

    group('SearchInterface', () {
      test('getItem returns ImageResponse', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success([testEntity]));

        final provider = createProvider();
        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));

        final item = provider.getItem(0);
        expect(item.id, testEntity.id);
        expect(item.format, testEntity.format);
      });

      test('getItemFormat returns correct format', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success([testEntity]));

        final provider = createProvider();
        provider.fetchMore(refresh: true);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.getItemFormat(0), ContentFormat.png);
      });

      test('getBooru delegates to prefModel', () {
        final provider = createProvider();
        expect(provider.getBooru(), Booru.derpi);
      });
    });

    group('changeFav', () {
      test('triggers refresh', () async {
        when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
            .thenAnswer((_) async => Success([testEntity]));

        final provider = createProvider();
        provider.changeFav();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(provider.state, isA<SuccessState<List<ImageEntity>>>());
        expect(provider.getItemCount(), 1);
        verify(() => mockRepo.getFavorites(Booru.derpi, 1, 20)).called(1);
      });
    });
  });
}
