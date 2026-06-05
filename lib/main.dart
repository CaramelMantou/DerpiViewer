import 'package:derpiviewer/ui/providers/connectivity_provider.dart';
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
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
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

class DVApp extends StatefulWidget {
  const DVApp({Key? key}) : super(key: key);

  @override
  State<DVApp> createState() => _DVAppState();
}

class _DVAppState extends State<DVApp> {
  late final PrefModel _prefModel;

  @override
  void initState() {
    super.initState();
    _prefModel = context.read<PrefModel>();
    _prefModel.addListener(_onPrefChanged);
  }

  @override
  void dispose() {
    _prefModel.removeListener(_onPrefChanged);
    super.dispose();
  }

  void _onPrefChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Derpiviewer',
      theme: AppTheme.defaultTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _prefModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      home: const HomePage(),
    );
  }
}
