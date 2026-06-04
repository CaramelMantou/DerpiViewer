import 'package:derpiviewer/core/domain/entities/image_entity.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/content_format.dart';
import 'package:derpiviewer/core/domain/enums/image_size.dart';
import 'package:derpiviewer/core/domain/failure_type.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/ui/providers/favorites_provider.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class _TestPrefModel extends PrefModel {
  _TestPrefModel() {
    booru = Booru.derpi;
    params.perPage = 20;
  }
}

final testEntity = ImageEntity(
  id: 1, booru: Booru.derpi,
  urls: {ImageSize.thumb: 'https://example.com/thumb.png'},
  format: ContentFormat.png, tags: ['safe'], tagIds: [1],
  description: 'Test', createdAt: '2024-01-01', duration: 0.0,
  upvotes: 10, downvotes: 1, comments: 0, faves: 5,
  uploader: 'Test', sourceUrls: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFavoritesRepository mockRepo;
  late _TestPrefModel prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockFavoritesRepository();
    prefs = _TestPrefModel();
  });

  FavoritesProvider createProvider() => FavoritesProvider(mockRepo, prefs);

  group('FavouritePage state transitions', () {
    test('empty list → SuccessState with empty data', () async {
      when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
          .thenAnswer((_) async => Success([]));

      final provider = createProvider();
      provider.fetchMore(refresh: true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.state, isA<SuccessState<List<ImageEntity>>>());
      final state = provider.state as SuccessState<List<ImageEntity>>;
      expect(state.data, isEmpty);
    });

    test('populated list → SuccessState with data', () async {
      when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
          .thenAnswer((_) async => Success([testEntity]));

      final provider = createProvider();
      provider.fetchMore(refresh: true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.state, isA<SuccessState<List<ImageEntity>>>());
      expect(provider.getItemCount(), 1);
    });

    test('fetch failure → FailureState', () async {
      when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
          .thenAnswer((_) async => Failure<List<ImageEntity>>('DB error', FailureType.unknown));

      final provider = createProvider();
      provider.fetchMore(refresh: true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.state, isA<FailureState<List<ImageEntity>>>());
      final state = provider.state as FailureState<List<ImageEntity>>;
      expect(state.message, 'DB error');
    });

    test('refresh clears and reloads data', () async {
      when(() => mockRepo.getFavorites(Booru.derpi, 1, 20))
          .thenAnswer((_) async => Success([testEntity]));

      final provider = createProvider();
      provider.fetchMore(refresh: true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.getItemCount(), 1);

      // Refresh with different data
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
}
