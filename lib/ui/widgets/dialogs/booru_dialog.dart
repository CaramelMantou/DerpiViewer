import 'package:derpiviewer/config/booru_config.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangeBooruDialog extends StatelessWidget {
  final PrefModel pref;
  const ChangeBooruDialog({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    Map<Booru, String> boorus = booruHosts;
    int booruNum = boorus.length;
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.drawerBooruTitle),
      children: <Widget>[
        for (var i = 0; i < booruNum; i++)
          generateOption(boorus[Booru.values[i]] ?? "", context, i)
      ],
    );
  }

  Widget generateOption(String text, BuildContext context, int idx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleDialogOption(
          onPressed: () {
            pref.changeHost(Booru.values[idx]);
            Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                msg: AppLocalizations.of(context)!
                    .drawerBooruSwitchMessage(text));
            Navigator.pop(context, null);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
