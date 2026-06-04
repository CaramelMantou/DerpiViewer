import 'package:derpiviewer/ui/providers/favorites_provider.dart';
import 'package:derpiviewer/ui/providers/search_provider.dart';
import 'package:derpiviewer/ui/providers/trending_provider.dart';
import 'package:flutter/material.dart';
import 'package:derpiviewer/pages/home_page.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/helpers/db.dart';
import 'package:derpiviewer/style/theme.dart';
import 'package:derpiviewer/core/di/injection_container.dart';
import 'package:derpiviewer/core/domain/repositories/favorites_repository.dart';
import 'package:derpiviewer/core/domain/repositories/image_repository.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await DbHelper.initDB();
  await configureDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PrefModel>(create: (context) => PrefModel()),
        ChangeNotifierProxyProvider<PrefModel, TrendingProvider>(
          create: (context) => TrendingProvider(
            resolve<ImageRepository>(),
            Provider.of<PrefModel>(context, listen: false),
          ),
          update: (context, value, previous) =>
              previous!..onPrefsChanged(value),
        ),
        ChangeNotifierProxyProvider<PrefModel, SearchProvider>(
          create: (context) => SearchProvider(
            resolve<ImageRepository>(),
            Provider.of<PrefModel>(context, listen: false),
          ),
          update: (context, value, previous) =>
              previous!..onPrefsChanged(value),
        ),
        ChangeNotifierProxyProvider<PrefModel, FavoritesProvider>(
            create: (context) => FavoritesProvider(
              resolve<FavoritesRepository>(),
              Provider.of<PrefModel>(context, listen: false),
            ),
            update: (context, value, previous) =>
                previous!..fetchMore(refresh: true)),
      ],
      child: const DVApp(),
    ),
  );
}

class DVApp extends StatelessWidget {
  const DVApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(
      builder: (context, prefModel, child) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          title: 'Derpiviewer',
          theme: AppTheme.defaultTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: prefModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          home: const HomePage(),
        );
      },
    );
  }
}
