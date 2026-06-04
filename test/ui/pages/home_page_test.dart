import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/ui/providers/connectivity_provider.dart';
import 'package:derpiviewer/ui/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Single setUpAll initialises SharedPreferences once so keys persist as they
  // would in the real app. Use distinct PrefModel instances to isolate state.
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ---------------------------------------------------------------------------
  // PrefModel unit tests
  // ---------------------------------------------------------------------------
  group('PrefModel', () {
    test('toggleDarkMode switches isDarkMode', () async {
      final prefs = PrefModel();
      prefs.getPref();

      final before = prefs.isDarkMode;
      prefs.toggleDarkMode();
      expect(prefs.isDarkMode, isNot(before));
    });

    test('toggleDarkMode is reversible', () async {
      final prefs = PrefModel();
      prefs.getPref();

      final original = prefs.isDarkMode;
      prefs.toggleDarkMode();
      prefs.toggleDarkMode();
      expect(prefs.isDarkMode, original);
    });

    test('changeHost updates booru field', () async {
      final prefs = PrefModel();
      prefs.getPref();

      prefs.changeHost(Booru.trixie);
      expect(prefs.booru, Booru.trixie);
    });

    test('sort direction defaults to desc', () async {
      final prefs = PrefModel();
      prefs.getPref();

      expect(prefs.params.sortDirection, SortDirection.desc);
    });

    test('sort field defaults to wilsonScore', () async {
      final prefs = PrefModel();
      prefs.getPref();

      expect(prefs.params.sortField, SortField.wilsonScore);
    });
  });

  // ---------------------------------------------------------------------------
  // HomeDrawer widget test
  // ---------------------------------------------------------------------------
  group('HomeDrawer', () {
    test('HomeDrawer can be instantiated', () {
      expect(const HomeDrawer(), isA<StatelessWidget>());
    });
  });

  // ---------------------------------------------------------------------------
  // ConnectivityProvider unit tests
  // ---------------------------------------------------------------------------
  group('ConnectivityProvider', () {
    test('starts with isOnline = false (pessimistic default)', () {
      final cp = ConnectivityProvider();
      expect(cp.isOnline, false);
    });

    test('is a ChangeNotifier', () {
      final cp = ConnectivityProvider();
      expect(cp, isA<ChangeNotifier>());
    });

    test('dispose does not throw', () {
      final cp = ConnectivityProvider();
      cp.dispose();
      // No exception thrown = pass
    });
  });
}
