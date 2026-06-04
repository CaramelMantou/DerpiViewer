import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';

class ChangeSlideIntervalDialog extends StatelessWidget {
  final PrefModel pref;
  const ChangeSlideIntervalDialog({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.slideshowDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.slideshowCurrentInterval('${pref.slideInterval}')),
          Slider(
            value: pref.slideInterval.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: l10n.slideshowIntervalValue(pref.slideInterval),
            onChanged: (value) {
              pref.setSlideInterval(value.round());
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogOk),
        ),
      ],
    );
  }
}
