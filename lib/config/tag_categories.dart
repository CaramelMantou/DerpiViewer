import 'package:flutter/material.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';

const Map<TagCategory, Color> tagBackColors = {
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
  TagCategory.origin: const Color.fromARGB(255, 185, 188, 225),
};

const Map<TagCategory, Color> tagForeColors = {
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
  TagCategory.origin: const Color.fromARGB(255, 57, 63, 133),
};

const List<String> ratingTags = [
  'explicit',
  'suggestive',
  'semi-grimdark',
  'safe',
  'grotesque',
  'questionable',
  'grimdark',
];

const List<String> bodyTags = [
  'unguligrade anthro',
  'two legged creature',
  'semi-anthro',
  'human head pony',
  'digitigrade anthro',
  'plantigrade anthro',
  'kemonomimi',
  'pony head on human body',
  'probably not salmon',
  'taur',
  'anthro',
];

const List<String> errorTags = [
  'dead source',
  'editor needed',
  'artist needed',
  'prompter needed',
  'oc name needed',
  'photographer needed',
  'useless source url',
  'source needed',
];
