import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Booru { derpi, trixie, pony, twi, fur, ponerpics, mane }

enum SortField {
  wilsonScore,
  created,
  updated,
  firstSeen,
  score,
  relevance,
  width,
  height,
  comments,
  tagCount
}

enum SortDirection { desc, asc }

// enum Filter { nofilter, defalta, everything }

enum Size { full, large, medium, small, thumb, thumbSmall, thumbTiny }

enum ContentFormat { gif, jpg, jpeg, png, svg, webm, mp4 }

enum TagCategory {
  general,
  artist,
  rating,
  character,
  oc,
  species,
  body,
  official,
  fanmade,
  origin,
  spoiler,
  error
}

class ConstStrings {
  static String defaultHost = 'trixiebooru.org';
  static String defaultSP = '/api/v1/json/search/images';
  static String defaultTP = "/api/v1/json/images/featured";
  static Map<Booru, String> boorus = {
    Booru.derpi: 'derpibooru.org',
    Booru.trixie: 'trixiebooru.org',
    Booru.pony: 'ponybooru.org',
    Booru.twi: 'twibooru.org',
    Booru.fur: 'furbooru.org',
    Booru.ponerpics: 'ponerpics.org',
    Booru.mane: 'manebooru.art'
  };
  static Map<Booru, String> searchPaths = {
    Booru.derpi: '/api/v1/json/search/images',
    Booru.trixie: '/api/v1/json/search/images',
    Booru.pony: '/api/v1/json/search/images',
    Booru.twi: '/api/v3/search/posts',
    Booru.fur: '/api/v1/json/search/images',
    Booru.ponerpics: '/api/v1/json/search/images',
    Booru.mane: '/api/v1/json/search/images'
  };
  static Map<Booru, String> trendingPaths = {
    Booru.derpi: "/api/v1/json/images/featured",
    Booru.trixie: "/api/v1/json/images/featured",
    Booru.pony: "/api/v1/json/images/featured",
    Booru.twi: '/api/v3/posts/featured',
    Booru.fur: '/api/v1/json/images/featured',
    Booru.ponerpics: '/api/v1/json/images/featured',
    Booru.mane: '/api/v1/json/images/featured'
  };
  static List<String> sfs = [
    "wilson_score",
    "created_at",
    "updated_at",
    "first_seen_at",
    "score",
    "relevance",
    "width",
    "height",
    "comments",
    "tag_count"
  ];

  static List<String> sds = ["desc", "asc"];

  static String getSfs(BuildContext ctx, SortField field) {
    switch (field) {
      case SortField.wilsonScore:
        return AppLocalizations.of(ctx)!.sf1;
      case SortField.created:
        return AppLocalizations.of(ctx)!.sf2;
      case SortField.updated:
        return AppLocalizations.of(ctx)!.sf3;
      case SortField.firstSeen:
        return AppLocalizations.of(ctx)!.sf4;
      case SortField.score:
        return AppLocalizations.of(ctx)!.sf5;
      case SortField.relevance:
        return AppLocalizations.of(ctx)!.sf6;
      case SortField.width:
        return AppLocalizations.of(ctx)!.sf7;
      case SortField.height:
        return AppLocalizations.of(ctx)!.sf8;
      case SortField.comments:
        return AppLocalizations.of(ctx)!.sf9;
      case SortField.tagCount:
        return AppLocalizations.of(ctx)!.sf10;
      default:
        return "";
    }
  }

  static String getSds(BuildContext ctx, SortDirection dir) {
    switch (dir) {
      case SortDirection.desc:
        return AppLocalizations.of(ctx)!.sd1;
      case SortDirection.asc:
        return AppLocalizations.of(ctx)!.sd2;
      default:
        return "";
    }
  }

  static String fallbackImg = "https://derpicdn.net/img/2012/1/2/1/medium.png";
  static List<String> format = [
    "gif",
    "jpg",
    "jpeg",
    "png",
    "svg",
    "webm",
    "mp4"
  ];
  static List<String> mime = [
    "image/gif",
    "image/jpeg",
    "image/jpeg",
    "image/png",
    "image/svg+xml",
    "video/webm",
    "video/mp4"
  ];
  static Map<Booru, Map<String, int>> filters = {
    Booru.derpi: {
      "Default": 100073,
      "Legacy Default": 37431,
      "18+ Dark": 37429,
      "Everything": 56027,
      "-safe": 201603,
      "18+ R34": 37432,
      "Maximum Spoilers": 37430,
    },
    Booru.trixie: {
      "Default": 100073,
      "Legacy Default": 37431,
      "18+ Dark": 37429,
      "Everything": 56027,
      "-safe": 201603,
      "18+ R34": 37432,
      "Maximum Spoilers": 37430,
    },
    Booru.pony: {"Default": 1, "Everything": 2},
    Booru.twi: {
      "Default": 1,
      "Wholesome": 9,
      "FiM Species Only": 139,
      "Not Imported": 113,
      "Pony Only": 6,
      "Everything EU": 8,
      "Everything": 2,
    },
    Booru.fur: {
      "Default": 1,
      "Everything (Furry Only)": 34,
      "Everything": 2,
      "Default 18+": 62,
      "Maximum Spoilers": 63,
    },
    Booru.ponerpics: {
      "Default": 1,
      "Wholesome Explicit": 3,
      "Everything": 2,
      "No Politics": 5,
      "EU Explicit": 4,
      "No Imports": 587,
      "No Anthro, Humanized, or Eqg": 108
    },
    Booru.mane: {
      "Default": 1,
      "Everything": 2,
      "Grimdark": 8,
      "NSFW+Grimdark": 9,
      "NSFW only": 7
    }
  };
  // color for all tagcategory
  static Map<TagCategory, Color> tagBackColors = {
    TagCategory.general: const Color.fromARGB(255, 208, 226, 156),
    TagCategory.artist: const Color.fromARGB(255, 185, 188, 225),
    TagCategory.error: const Color.fromARGB(255, 238, 177, 188),
    TagCategory.fanmade: const Color.fromARGB(255, 239, 215, 231),
    TagCategory.rating: const Color.fromARGB(255, 193, 215, 228),
    TagCategory.body: const Color.fromARGB(255, 193, 193, 193),
    TagCategory.character: const Color.fromARGB(255, 181, 223, 216),
    TagCategory.oc: const Color.fromARGB(255, 222, 197, 226),
    TagCategory.official: const Color.fromARGB(255, 237, 230, 151),
    TagCategory.spoiler: const Color.fromARGB(255, 244, 205, 194),
    TagCategory.species: const Color.fromARGB(255, 230, 201, 181),
    TagCategory.origin: const Color.fromARGB(255, 185, 188, 225)
  };
  static Map<TagCategory, Color> tagForeColors = {
    TagCategory.general: const Color.fromARGB(255, 111, 143, 14),
    TagCategory.artist: const Color.fromARGB(255, 57, 63, 133),
    TagCategory.error: const Color.fromARGB(255, 173, 38, 63),
    TagCategory.fanmade: const Color.fromARGB(255, 187, 84, 150),
    TagCategory.rating: const Color.fromARGB(255, 38, 126, 173),
    TagCategory.body: const Color.fromARGB(255, 78, 78, 78),
    TagCategory.character: const Color.fromARGB(255, 45, 134, 119),
    TagCategory.oc: const Color.fromARGB(255, 152, 82, 163),
    TagCategory.official: const Color.fromARGB(255, 153, 142, 26),
    TagCategory.spoiler: const Color.fromARGB(255, 194, 69, 35),
    TagCategory.species: const Color.fromARGB(255, 139, 85, 47),
    TagCategory.origin: const Color.fromARGB(255, 57, 63, 133)
  };
  static List<String> ratingTags = [
    "explicit",
    "suggestive",
    "semi-grimdark",
    "safe",
    "grotesque",
    "questionable",
    "grimdark"
  ];
  static List<String> bodyTags = [
    "unguligrade anthro",
    "two legged creature",
    "semi-anthro",
    "human head pony",
    "digitigrade anthro",
    "plantigrade anthro",
    "kemonomimi",
    "pony head on human body",
    "probably not salmon",
    "taur",
    "anthro",
  ];
  static List<String> errorTags = [
    "dead source",
    "editor needed",
    "artist needed",
    "prompter needed",
    "oc name needed",
    "photographer needed",
    "useless source url",
    "source needed",
  ];
}
