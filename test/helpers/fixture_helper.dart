import 'dart:convert';
import 'dart:io';

/// Loads a JSON fixture file from `test/fixtures/` and returns it as a Map.
///
/// Usage:
/// ```dart
/// final json = loadFixture('derpi_image.json');
/// ```
Map<String, dynamic> loadFixture(String name) {
  final file = File('test/fixtures/$name');
  final content = file.readAsStringSync();
  return jsonDecode(content) as Map<String, dynamic>;
}
