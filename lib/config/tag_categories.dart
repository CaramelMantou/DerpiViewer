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

/// Light-theme foreground colors — original values preserved.
/// Designed for readability against light scaffold (#FFFFFF).
const Map<TagCategory, Color> tagForeColorsLight = {
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

/// Dark-theme foreground colors — computed for ≥4.5:1 WCAG AA contrast
/// against each category's [tagBackColors] entry.
///
/// Derived by preserving hue and saturation from the original light-mode
/// foreground while reducing lightness to meet the AA threshold against
/// the unchanged chip backgrounds. Each value maintains the category's
/// color identity (e.g., general=dark olive, artist=dark navy,
/// error=dark rose, rating=dark teal-blue).
const Map<TagCategory, Color> tagForeColorsDark = {
  // general: bg #D0E29C → dark olive (6.8:1)
  TagCategory.general: const Color.fromARGB(255, 59, 76, 7),
  // artist: bg #B9BCE1 → dark navy (8.3:1)
  TagCategory.artist: const Color.fromARGB(255, 30, 33, 70),
  // error: bg #EEB1BC → dark rose (7.4:1)
  TagCategory.error: const Color.fromARGB(255, 91, 20, 33),
  // fanmade: bg #EFD7E7 → dark magenta (7.9:1)
  TagCategory.fanmade: const Color.fromARGB(255, 101, 40, 79),
  // rating: bg #C1D7E4 → dark teal-blue (7.2:1)
  TagCategory.rating: const Color.fromARGB(255, 20, 66, 91),
  // body: bg #C1C1C1 → dark gray (8.0:1) — was invisible at 1.9:1 against scaffold
  TagCategory.body: const Color.fromARGB(255, 42, 42, 42),
  // character: bg #B5DFD8 → dark teal (7.2:1)
  TagCategory.character: const Color.fromARGB(255, 24, 71, 63),
  // oc: bg #DEC5E2 → dark purple (7.3:1)
  TagCategory.oc: const Color.fromARGB(255, 79, 43, 85),
  // official: bg #EDE697 → dark gold (6.9:1)
  TagCategory.official: const Color.fromARGB(255, 81, 75, 14),
  // spoiler: bg #F4CDC2 → dark coral (7.9:1)
  TagCategory.spoiler: const Color.fromARGB(255, 101, 36, 18),
  // species: bg #E6C9B5 → dark brown (8.0:1)
  TagCategory.species: const Color.fromARGB(255, 73, 45, 25),
  // origin: bg #B9BCE1 → dark navy (8.3:1)— same bg as artist
  TagCategory.origin: const Color.fromARGB(255, 30, 33, 70),
};

/// Returns the correct tag foreground color for the current theme brightness.
///
/// Falls back to [Colors.white] in dark mode and [Colors.black] in light mode
/// if a category is missing from the color maps (e.g., after adding a new
/// [TagCategory] enum value without updating the maps).
///
/// Usage:
/// ```dart
/// TextStyle(color: tagForeColor(tc, Theme.of(context).brightness))
/// ```
Color tagForeColor(TagCategory category, Brightness brightness) {
  return brightness == Brightness.dark
      ? tagForeColorsDark[category] ?? Colors.white
      : tagForeColorsLight[category] ?? Colors.black;
}

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
