import 'package:derpiviewer/core/data/datasources/strategies/philomena_v3_strategy.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixture_helper.dart';

void main() {
  late PhilomenaV3Strategy strategy;

  setUp(() {
    strategy = PhilomenaV3Strategy('twibooru.org', Booru.twi);
  });

  group('PhilomenaV3Strategy', () {
    group('paths', () {
      test('searchPath is v3 search path', () {
        expect(strategy.searchPath, '/api/v3/search/posts');
      });

      test('trendingPath is v3 featured path', () {
        expect(strategy.trendingPath, '/api/v3/posts/featured');
      });

      test('imagePath formats correctly', () {
        expect(strategy.imagePath(456), '/api/v3/posts/456');
      });

      test('host is the configured host', () {
        expect(strategy.host, 'twibooru.org');
      });
    });

    group('parseImageList', () {
      test('extracts from data["posts"]', () {
        final json = loadFixture('twi_featured.json');
        final searchJson = {'posts': [json['post']]};
        final images = strategy.parseImageList(searchJson);
        expect(images.length, 1);
        expect(images[0].id, 100);
      });

      test('extracted DTO has correct fields', () {
        final json = loadFixture('twi_featured.json');
        final searchJson = {'posts': [json['post']]};
        final images = strategy.parseImageList(searchJson);
        expect(images[0].format, 'png');
        expect(images[0].tags, contains('featured'));
        expect(images[0].tags, contains('twilight sparkle'));
      });
    });

    group('parseImage', () {
      test('extracts image from data["post"]', () {
        final json = loadFixture('twi_featured.json');
        final image = strategy.parseImage(json);
        expect(image.id, 100);
        expect(image.format, 'png');
      });

      test('extracts correct fields', () {
        final json = loadFixture('twi_featured.json');
        final image = strategy.parseImage(json);
        expect(image.id, 100);
        expect(image.format, 'png');
        expect(image.tags, contains('featured'));
        expect(image.tagIds, [1, 2]);
        expect(image.description, 'Featured post on Twibooru');
        expect(image.uploader, 'FeatureUploader');
        expect(image.upvotes, 500);
        expect(image.downvotes, 5);
        expect(image.comments, 30);
        expect(image.faves, 200);
      });
    });

    group('parseFeatured', () {
      test('extracts featured image from data["post"]', () {
        final json = loadFixture('twi_featured.json');
        final image = strategy.parseFeatured(json);
        expect(image.id, 100);
        expect(image.description, 'Featured post on Twibooru');
        expect(image.upvotes, 500);
        expect(image.faves, 200);
      });

      test('extracts all URL fields', () {
        final json = loadFixture('twi_featured.json');
        final image = strategy.parseFeatured(json);
        expect(image.fullUrl, contains('100.png'));
        expect(image.largeUrl, contains('100_large.png'));
        expect(image.mediumUrl, contains('100_medium.png'));
        expect(image.smallUrl, contains('100_small.png'));
        expect(image.thumbUrl, contains('100_thumb.png'));
        expect(image.thumbSmallUrl, contains('100_thumb_small.png'));
        expect(image.thumbTinyUrl, contains('100_thumb_tiny.png'));
      });
    });
  });
}
