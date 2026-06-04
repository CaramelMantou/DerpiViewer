import 'dart:math';

import 'package:derpiviewer/config/tag_categories.dart';
import 'package:derpiviewer/core/domain/enums/tag_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio using Flutter's built-in [Color.computeLuminance].
double contrastRatio(Color bg, Color fg) {
  final l1 = bg.computeLuminance();
  final l2 = fg.computeLuminance();
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('tag_categories.dart — dual-theme foreground colors', () {
    // ================================================================
    // tagBackColors — unchanged
    // ================================================================
    test('tagBackColors has 12 entries (one per TagCategory)', () {
      expect(tagBackColors.length, 12);
      for (final category in TagCategory.values) {
        expect(tagBackColors.containsKey(category), isTrue,
            reason: 'Missing tagBackColors entry for $category');
      }
    });

    // ================================================================
    // tagForeColorsLight — renamed from tagForeColors
    // ================================================================
    test('tagForeColorsLight has 12 entries matching previous tagForeColors values', () {
      expect(tagForeColorsLight.length, 12);
      for (final category in TagCategory.values) {
        expect(tagForeColorsLight.containsKey(category), isTrue,
            reason: 'Missing tagForeColorsLight entry for $category');
      }
    });

    // ================================================================
    // tagForeColorsDark — new 12-entry map
    // ================================================================
    test('tagForeColorsDark has 12 entries', () {
      expect(tagForeColorsDark.length, 12);
      for (final category in TagCategory.values) {
        expect(tagForeColorsDark.containsKey(category), isTrue,
            reason: 'Missing tagForeColorsDark entry for $category');
      }
    });

    // ================================================================
    // Contrast: each dark foreground ≥4.5:1 against its tagBackColors
    // ================================================================
    test('every dark foreground meets WCAG AA contrast ≥4.5:1 against its background', () {
      final failures = <String>[];
      for (final category in TagCategory.values) {
        final bg = tagBackColors[category]!;
        final fg = tagForeColorsDark[category]!;
        final ratio = contrastRatio(bg, fg);
        if (ratio < 4.5) {
          failures.add(
            '$category: bg=${bg.toARGB32()} fg=${fg.toARGB32()} '
            'ratio=${ratio.toStringAsFixed(1)}:1 (needs ≥4.5:1)',
          );
        }
      }
      expect(failures, isEmpty,
          reason: '${failures.length} categories fail contrast: ${failures.join('; ')}');
    });

    // ================================================================
    // tagForeColor helper — returns correct color per brightness
    // ================================================================
    group('tagForeColor helper', () {
      test('returns light foreground for Brightness.light', () {
        for (final category in TagCategory.values) {
          expect(
            tagForeColor(category, Brightness.light),
            tagForeColorsLight[category],
            reason: 'Wrong light foreground for $category',
          );
        }
      });

      test('returns dark foreground for Brightness.dark', () {
        for (final category in TagCategory.values) {
          expect(
            tagForeColor(category, Brightness.dark),
            tagForeColorsDark[category],
            reason: 'Wrong dark foreground for $category',
          );
        }
      });
    });

    // ================================================================
    // Body category fix — was 1.9:1 against dark scaffold (#4E4E4E)
    // ================================================================
    test('body category dark foreground is not #4E4E4E (the old invisible value)', () {
      final bodyDark = tagForeColorsDark[TagCategory.body]!;
      // The old #4E4E4E value had 1.9:1 contrast — it MUST be replaced
      expect(bodyDark, isNot(const Color.fromARGB(255, 78, 78, 78)));
    });

    // ================================================================
    // Light theme unchanged — tagForeColorsLight == old tagForeColors
    // ================================================================
    test('light foreground preserves original tagForeColors values', () {
      // These are the pre-existing light-mode foreground values.
      // tagForeColorsLight MUST match them exactly.
      expect(tagForeColorsLight[TagCategory.general], const Color.fromARGB(255, 111, 143, 14));
      expect(tagForeColorsLight[TagCategory.artist], const Color.fromARGB(255, 57, 63, 133));
      expect(tagForeColorsLight[TagCategory.error], const Color.fromARGB(255, 173, 38, 63));
      expect(tagForeColorsLight[TagCategory.fanmade], const Color.fromARGB(255, 187, 84, 150));
      expect(tagForeColorsLight[TagCategory.rating], const Color.fromARGB(255, 38, 126, 173));
      expect(tagForeColorsLight[TagCategory.body], const Color.fromARGB(255, 78, 78, 78));
      expect(tagForeColorsLight[TagCategory.character], const Color.fromARGB(255, 45, 134, 119));
      expect(tagForeColorsLight[TagCategory.oc], const Color.fromARGB(255, 152, 82, 163));
      expect(tagForeColorsLight[TagCategory.official], const Color.fromARGB(255, 153, 142, 26));
      expect(tagForeColorsLight[TagCategory.spoiler], const Color.fromARGB(255, 194, 69, 35));
      expect(tagForeColorsLight[TagCategory.species], const Color.fromARGB(255, 139, 85, 47));
      expect(tagForeColorsLight[TagCategory.origin], const Color.fromARGB(255, 57, 63, 133));
    });
  });
}
