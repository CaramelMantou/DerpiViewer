import 'package:derpiviewer/core/data/datasources/strategies/philomena_v1_strategy.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixture_helper.dart';

void main() {
  late PhilomenaV1Strategy strategy;

  setUp(() {
    strategy = PhilomenaV1Strategy('derpibooru.org', Booru.derpi);
  });

  group('PhilomenaV1Strategy', () {
    group('paths', () {
      test('searchPath is v1 search path', () {
        expect(strategy.searchPath, '/api/v1/json/search/images');
      });

      test('trendingPath is v1 featured path', () {
        expect(strategy.trendingPath, '/api/v1/json/images/featured');
      });

      test('imagePath formats correctly', () {
        expect(strategy.imagePath(123), '/api/v1/json/images/123');
      });

      test('host is the configured host', () {
        expect(strategy.host, 'derpibooru.org');
      });
    });

    group('parseImageList', () {
      test('extracts correct count from fixture', () {
        final json = loadFixture('trixie_search.json');
        final images = strategy.parseImageList(json);
        expect(images.length, 2);
      });

      test('extracted DTOs have correct IDs', () {
        final json = loadFixture('trixie_search.json');
        final images = strategy.parseImageList(json);
        expect(images[0].id, 1);
        expect(images[1].id, 2);
      });

      test('extracts from data["images"] key — explicit construction', () {
        final imageJson = loadFixture('derpi_image.json')['image'];
        final searchJson = <String, dynamic>{
          'images': [imageJson],
        };
        final images = strategy.parseImageList(searchJson);
        expect(images.length, 1);
        expect(images[0].id, 0);
        expect(images[0].format, 'png');
      });
    });

    group('parseImage', () {
      test('extracts image from data["image"]', () {
        final json = loadFixture('derpi_image.json');
        final image = strategy.parseImage(json);
        expect(image.id, 0);
        expect(image.format, 'png');
      });

      test('extracts correct fields', () {
        final json = loadFixture('derpi_image.json');
        final image = strategy.parseImage(json);
        expect(image.id, 0);
        expect(image.format, 'png');
        expect(image.tags, ['safe', 'solo']);
        expect(image.tagIds, [1, 2]);
        expect(image.description, 'Test image');
        expect(image.uploader, 'TestUploader');
        expect(image.upvotes, 100);
        expect(image.downvotes, 10);
        expect(image.comments, 5);
        expect(image.faves, 50);
      });

      test('extracts all URL fields', () {
        final json = loadFixture('derpi_image.json');
        final image = strategy.parseImage(json);
        expect(image.fullUrl, contains('0.png'));
        expect(image.largeUrl, contains('0_large.png'));
        expect(image.mediumUrl, contains('0_medium.png'));
        expect(image.smallUrl, contains('0_small.png'));
        expect(image.thumbUrl, contains('0_thumb.png'));
        expect(image.thumbSmallUrl, contains('0_thumb_small.png'));
        expect(image.thumbTinyUrl, contains('0_thumb_tiny.png'));
      });
    });

    group('parseFeatured', () {
      test('extracts featured image from data["image"]', () {
        final json = loadFixture('derpi_image.json');
        final image = strategy.parseFeatured(json);
        expect(image.id, 0);
        expect(image.format, 'png');
      });
    });
  });
}
