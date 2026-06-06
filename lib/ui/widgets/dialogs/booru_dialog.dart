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
    // TODO: re-enable trixie after fixing trixiebooru bugs
    final entries = booruHosts.entries
        .where((e) => e.key != Booru.trixie)
        .toList();
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.drawerBooruTitle),
      children: <Widget>[
        for (final entry in entries)
          generateOption(entry.key, entry.value, context)
      ],
    );
  }

  Widget generateOption(Booru booru, String text, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleDialogOption(
          onPressed: () {
            pref.changeHost(booru);
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
