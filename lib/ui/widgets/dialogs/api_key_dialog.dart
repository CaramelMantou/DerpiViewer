import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeKeyDialog extends StatelessWidget {
  const ChangeKeyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      TextEditingController textController =
          TextEditingController(text: pref.key);
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawerApiTitle),
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: textController,
                  onSubmitted: ((value) {
                    pref.updateKey(value);
                  }),
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "API Key",
                      icon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textController.clear();
                          })))),
          Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Text(
                AppLocalizations.of(context)!.drawerApiHint,
                style: const TextStyle(fontSize: 12),
              )),
          const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: SelectableText(
                "https://derpibooru.org/registrations/edit",
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ))
        ],
      );
    }));
  }
}
