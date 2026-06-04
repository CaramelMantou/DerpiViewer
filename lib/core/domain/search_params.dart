import 'package:derpiviewer/core/domain/enums/sort_direction.dart';
import 'package:derpiviewer/core/domain/enums/sort_field.dart';

/// Immutable value object for search query parameters.
///
/// Domain-layer class with no Flutter or data-layer dependencies.
/// [filterId] is nullable — `null` means "no filter" (booru-agnostic).
class SearchParams {
  final int? filterId;
  final int perPage;
  final SortDirection sortDirection;
  final SortField sortField;
  final int page;

  const SearchParams({
    this.filterId,
    this.perPage = 18,
    this.sortDirection = SortDirection.desc,
    this.sortField = SortField.wilsonScore,
    this.page = 1,
  });
}
