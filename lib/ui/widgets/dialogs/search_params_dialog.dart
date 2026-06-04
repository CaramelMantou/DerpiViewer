import 'package:derpiviewer/config/booru_config.dart';
import 'package:derpiviewer/config/constants.dart';
import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeParamDialog extends StatelessWidget {
  const ChangeParamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrefModel>(builder: ((context, pref, child) {
      Map<String, int> curFilters = booruFilters[pref.booru]!;
      return SimpleDialog(
        title: Text(AppLocalizations.of(context)!.drawerSearchTitle),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<SortDirection>(
              leadingIcon: const Icon(Icons.sort),
              width: MediaQuery.of(context).size.width * 0.7,
              label:
                  Text(AppLocalizations.of(context)!.drawerSearchSortDirection),
              initialSelection: pref.params.sortDirection,
              onSelected: (value) {
                if (value != null) {
                  pref.updateParams(sd: value);
                }
              },
              dropdownMenuEntries: [
                for (SortDirection i in SortDirection.values)
                  DropdownMenuEntry<SortDirection>(
                    value: i,
                    label: getSortDirectionLabel(context, i),
                  )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<SortField>(
              leadingIcon: const Icon(Icons.filter_list),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSearchSortField),
              initialSelection: pref.params.sortField,
              onSelected: (value) {
                if (value != null) {
                  pref.updateParams(sf: value);
                  Navigator.pop(context, null);
                }
              },
              dropdownMenuEntries: [
                for (SortField i in SortField.values)
                  DropdownMenuEntry<SortField>(
                    value: i,
                    label: getSortFieldLabel(context, i),
                  )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownMenu<String>(
              leadingIcon: const Icon(Icons.filter_alt),
              width: MediaQuery.of(context).size.width * 0.7,
              label: Text(AppLocalizations.of(context)!.drawerSearchFilter),
              initialSelection: pref.params.filterName,
              onSelected: (value) {
                if (value != null) {
                  pref.updateParams(fid: curFilters[value], fn: value);
                  Navigator.pop(context, null);
                }
              },
              dropdownMenuEntries: [
                for (String s in curFilters.keys)
                  DropdownMenuEntry<String>(
                    value: s,
                    label: s,
                  )
              ],
            ),
          ),
        ],
      );
    }));
  }
}
