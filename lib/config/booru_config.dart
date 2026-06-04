import 'package:derpiviewer/core/domain/enums/booru.dart';

const String defaultHost = 'trixiebooru.org';
const String defaultSearchPath = '/api/v1/json/search/images';
const String defaultTrendingPath = '/api/v1/json/images/featured';

const Map<Booru, String> booruHosts = {
  Booru.derpi: 'derpibooru.org',
  Booru.trixie: 'trixiebooru.org',
  Booru.pony: 'ponybooru.org',
  Booru.twi: 'twibooru.org',
  Booru.fur: 'furbooru.org',
  Booru.ponerpics: 'ponerpics.org',
  Booru.mane: 'manebooru.art',
};

const Map<Booru, String> booruSearchPaths = {
  Booru.derpi: '/api/v1/json/search/images',
  Booru.trixie: '/api/v1/json/search/images',
  Booru.pony: '/api/v1/json/search/images',
  Booru.twi: '/api/v3/search/posts',
  Booru.fur: '/api/v1/json/search/images',
  Booru.ponerpics: '/api/v1/json/search/images',
  Booru.mane: '/api/v1/json/search/images',
};

const Map<Booru, String> booruTrendingPaths = {
  Booru.derpi: '/api/v1/json/images/featured',
  Booru.trixie: '/api/v1/json/images/featured',
  Booru.pony: '/api/v1/json/images/featured',
  Booru.twi: '/api/v3/posts/featured',
  Booru.fur: '/api/v1/json/images/featured',
  Booru.ponerpics: '/api/v1/json/images/featured',
  Booru.mane: '/api/v1/json/images/featured',
};

const Map<Booru, Map<String, int>> booruFilters = {
  Booru.derpi: {
    'Default': 100073,
    'Legacy Default': 37431,
    '18+ Dark': 37429,
    'Everything': 56027,
    '-safe': 201603,
    '18+ R34': 37432,
    'Maximum Spoilers': 37430,
  },
  Booru.trixie: {
    'Default': 100073,
    'Legacy Default': 37431,
    '18+ Dark': 37429,
    'Everything': 56027,
    '-safe': 201603,
    '18+ R34': 37432,
    'Maximum Spoilers': 37430,
  },
  Booru.pony: {'Default': 1, 'Everything': 2},
  Booru.twi: {
    'Default': 1,
    'Wholesome': 9,
    'FiM Species Only': 139,
    'Not Imported': 113,
    'Pony Only': 6,
    'Everything EU': 8,
    'Everything': 2,
  },
  Booru.fur: {
    'Default': 1,
    'Everything (Furry Only)': 34,
    'Everything': 2,
    'Default 18+': 62,
    'Maximum Spoilers': 63,
  },
  Booru.ponerpics: {
    'Default': 1,
    'Wholesome Explicit': 3,
    'Everything': 2,
    'No Politics': 5,
    'EU Explicit': 4,
    'No Imports': 587,
    'No Anthro, Humanized, or Eqg': 108,
  },
  Booru.mane: {
    'Default': 1,
    'Everything': 2,
    'Grimdark': 8,
    'NSFW+Grimdark': 9,
    'NSFW only': 7,
  },
};
