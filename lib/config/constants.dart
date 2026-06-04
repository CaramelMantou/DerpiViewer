import 'package:flutter/widgets.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';
import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';

const String fallbackImg = 'https://derpicdn.net/img/2012/1/2/1/medium.png';

const List<String> formatExtensions = [
  'gif',
  'jpg',
  'jpeg',
  'png',
  'svg',
  'webm',
  'mp4',
];

const List<String> mimeTypes = [
  'image/gif',
  'image/jpeg',
  'image/jpeg',
  'image/png',
  'image/svg+xml',
  'video/webm',
  'video/mp4',
];

const List<String> sortFields = [
  'wilson_score',
  'created_at',
  'updated_at',
  'first_seen_at',
  'score',
  'relevance',
  'width',
  'height',
  'comments',
  'tag_count',
];

const List<String> sortDirections = ['desc', 'asc'];

String getSortFieldLabel(BuildContext ctx, SortField field) {
  switch (field) {
    case SortField.wilsonScore:
      return AppLocalizations.of(ctx)!.sortFieldWilson;
    case SortField.created:
      return AppLocalizations.of(ctx)!.sortFieldId;
    case SortField.updated:
      return AppLocalizations.of(ctx)!.sortFieldUpdated;
    case SortField.firstSeen:
      return AppLocalizations.of(ctx)!.sortFieldFirstSeen;
    case SortField.score:
      return AppLocalizations.of(ctx)!.sortFieldScore;
    case SortField.relevance:
      return AppLocalizations.of(ctx)!.sortFieldRelevance;
    case SortField.width:
      return AppLocalizations.of(ctx)!.sortFieldWidth;
    case SortField.height:
      return AppLocalizations.of(ctx)!.sortFieldHeight;
    case SortField.comments:
      return AppLocalizations.of(ctx)!.sortFieldComments;
    case SortField.tagCount:
      return AppLocalizations.of(ctx)!.sortFieldTagCount;
  }
}

String getSortDirectionLabel(BuildContext ctx, SortDirection dir) {
  switch (dir) {
    case SortDirection.desc:
      return AppLocalizations.of(ctx)!.sortDirectionDesc;
    case SortDirection.asc:
      return AppLocalizations.of(ctx)!.sortDirectionAsc;
  }
}
