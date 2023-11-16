import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';
import 'package:derpiviewer/enums.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeBooruDialog extends StatelessWidget {
  final PrefModel pref;
  const ChangeBooruDialog({super.key, required this.pref});
  @override
  Widget build(BuildContext context) {
    Map<Booru, String> boorus = ConstStrings.boorus;
    int booruNum = boorus.length;
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.drawer1t),
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
                msg: AppLocalizations.of(context)!.drawer1n1(text));
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
        const Divider(), // 添加分割线
      ],
    );
  }
}

class ChangeParamDialog extends StatelessWidget {
  const ChangeParamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      Map<String, int> curFilters = ConstStrings.filters[pref.booru]!;
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawer2t),
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<SortDirection>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.arrow_upward),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer2i1t),
                  items: [
                    for (SortDirection i in SortDirection.values)
                      DropdownMenuItem<SortDirection>(
                        value: i,
                        child: Text(ConstStrings.getSds(context, i)),
                      )
                  ],
                  value: pref.params.sortDirection,
                  onChanged: ((value) {
                    pref.updateParams(sd: value);
                  }))),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<SortField>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.sort),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer2i2t),
                  items: [
                    for (SortField i in SortField.values)
                      DropdownMenuItem<SortField>(
                        value: i,
                        child: Text(ConstStrings.getSfs(context, i)),
                      )
                  ],
                  value: pref.params.sortField,
                  onChanged: ((value) {
                    pref.updateParams(sf: value);
                    Navigator.pop(context, null);
                  }))),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.filter_alt),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer2i3t),
                  value: pref.params.filterName,
                  items: [
                    for (String s in curFilters.keys)
                      DropdownMenuItem(value: s, child: Text(s))
                  ],
                  onChanged: ((value) {
                    pref.updateParams(fid: curFilters[value], fn: value);
                    Navigator.pop(context, null);
                  })))
        ],
      );
    }));
  }
}

class ChangeDownloadPrefDialog extends StatelessWidget {
  const ChangeDownloadPrefDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawer3t),
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<Size>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.image),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer3i1t),
                  items: const [
                    DropdownMenuItem<Size>(
                      value: Size.full,
                      child: Text("Full"),
                    ),
                    DropdownMenuItem<Size>(
                      value: Size.large,
                      child: Text("Large"),
                    )
                  ],
                  value: pref.imageSize,
                  onChanged: ((value) {
                    pref.imageSize = value ?? pref.imageSize;
                  }))),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<Size>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.video_file),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer3i2t),
                  items: const [
                    DropdownMenuItem<Size>(
                      value: Size.full,
                      child: Text("Full"),
                    ),
                    DropdownMenuItem<Size>(
                      value: Size.medium,
                      child: Text("Medium"),
                    )
                  ],
                  value: pref.videoSize,
                  onChanged: ((value) {
                    pref.videoSize = value ?? pref.videoSize;
                  }))),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<Size>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.download),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer3i3t),
                  items: const [
                    DropdownMenuItem<Size>(
                      value: Size.full,
                      child: Text("Full"),
                    ),
                    DropdownMenuItem<Size>(
                      value: Size.large,
                      child: Text("Large"),
                    )
                  ],
                  value: pref.downloadSize,
                  onChanged: ((value) {
                    pref.downloadSize = value ?? pref.downloadSize;
                  }))),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<Size>(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.share),
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.drawer3i4t),
                  items: const [
                    DropdownMenuItem<Size>(
                      value: Size.full,
                      child: Text("Full"),
                    ),
                    DropdownMenuItem<Size>(
                      value: Size.large,
                      child: Text("Large"),
                    ),
                    DropdownMenuItem<Size>(
                      value: Size.medium,
                      child: Text("Medium"),
                    )
                  ],
                  value: pref.shareSize,
                  onChanged: ((value) {
                    pref.shareSize = value ?? pref.shareSize;
                    Navigator.pop(context, null);
                  }))),
        ],
      );
    }));
  }
}

class ChangeKeyDialog extends StatelessWidget {
  const ChangeKeyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      TextEditingController textController =
          TextEditingController(text: pref.key);
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawer4t),
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: textController,
                  onSubmitted: ((value) {
                    pref.updateKey(value);
                  }),
                  //Header
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
                AppLocalizations.of(context)!.drawer4i1t,
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
