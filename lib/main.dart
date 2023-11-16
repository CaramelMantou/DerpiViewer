import 'package:derpiviewer/models/fav_model.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:flutter/material.dart';
import 'package:derpiviewer/pages/home_page.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/models/trending_model.dart';
import 'package:derpiviewer/helpers/db.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await DbHelper.initDB();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PrefModel>(create: (context) => PrefModel()),
        ChangeNotifierProxyProvider<PrefModel, TrendingModel>(
            create: (context) =>
                TrendingModel(Provider.of<PrefModel>(context, listen: false)),
            update: (_, value, previous) =>
                previous!..fetchMore(refresh: true)),
        ChangeNotifierProxyProvider<PrefModel, SearchModel>(
            create: (context) =>
                SearchModel(Provider.of<PrefModel>(context, listen: false)),
            update: (context, value, previous) =>
                previous!..fetchMore(refresh: true)),
        ChangeNotifierProxyProvider<PrefModel, FavModel>(
            create: (context) =>
                FavModel(Provider.of<PrefModel>(context, listen: false)),
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
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Derpiviewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
