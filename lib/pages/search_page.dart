import 'package:derpiviewer/config/tag_categories.dart';
import 'package:derpiviewer/core/di/injection_container.dart';
import 'package:derpiviewer/core/domain/enums/booru.dart';
import 'package:derpiviewer/core/domain/repositories/favorite_tags_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/helpers/helper.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:derpiviewer/ui/providers/search_provider.dart';
import 'package:derpiviewer/ui/widgets/dialogs/add_favorite_tag_dialog.dart';
import 'package:flutter/material.dart';
import 'package:derpiviewer/pages/result_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  final String? initQuery;
  const SearchPage({super.key, this.initQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();
  late String _initQuery;
  bool _isSearchEnabled = false;
  List<String> _favoriteTags = [];

  @override
  void initState() {
    _initQuery = widget.initQuery ?? "";
    _textController.text = _initQuery;
    _isSearchEnabled = _initQuery.isNotEmpty;
    _textController.addListener(_onTextChanged);
    _loadFavoriteTags();
    super.initState();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final enabled = _textController.text.isNotEmpty;
    if (enabled != _isSearchEnabled) {
      setState(() {
        _isSearchEnabled = enabled;
      });
    }
  }

  void _loadFavoriteTags() {
    final repository = resolve<FavoriteTagsRepository>();
    repository.getAllTags().then((result) {
      if (!mounted) return;
      if (result is Success<List<String>>) {
        setState(() {
          _favoriteTags = List<String>.from(result.data);
        });
      } else if (result is Failure<List<String>>) {
        Fluttertoast.showToast(msg: result.message);
      }
    });
  }

  void _appendTagToInput(String tag) {
    final current = _textController.text;
    final trimmed = current.replaceAll(RegExp(r',\s*$'), '');
    final tags = trimmed
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    if (tags.contains(tag)) return;
    final sep = trimmed.isEmpty ? '' : ', ';
    final newText = '$trimmed$sep$tag';
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<void> _deleteFavoriteTag(String tag) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.searchDeleteTagTitle),
        content: Text('"$tag" — ${l10n.searchDeleteTagConfirm}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.toolbarConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.toolbarConfirmOk),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repository = resolve<FavoriteTagsRepository>();
    repository.removeTag(tag).then((result) {
      if (!mounted) return;
      if (result is Success<void>) {
        setState(() {
          _favoriteTags.remove(tag);
        });
        Fluttertoast.showToast(msg: l10n.searchTagDeleted);
      } else if (result is Failure<void>) {
        Fluttertoast.showToast(msg: result.message);
      }
    });
  }

  Future<void> _showAddDialog() async {
    final tag = await showDialog<String>(
      context: context,
      builder: (_) => const AddFavoriteTagDialog(),
    );
    if (tag != null && mounted && !_favoriteTags.contains(tag)) {
      setState(() {
        _favoriteTags.add(tag);
      });
    }
  }

  void showResult(query) {
    if (query.isEmpty) return;
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.newSearch(query);
    searchProvider.addHistory(query);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(
                  query: query,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.tooltipBack,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          title: InputHistoryTextField(
            historyKey: "histoire",
            textEditingController: _textController,
            onSubmitted: ((value) => showResult(value)),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
                hintText: l10n.searchHint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Theme.of(context).iconTheme.color)),
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            cursorColor:
                Theme.of(context).floatingActionButtonTheme.foregroundColor,
            deleteIconColor: Theme.of(context).iconTheme.color,
            historyIconColor: Theme.of(context).iconTheme.color,
            style: TextStyle(
              color: Theme.of(context)
                  .floatingActionButtonTheme
                  .foregroundColor,
            ),
          ),
          actions: [
            IconButton(
              tooltip: l10n.searchAddFavoriteTag,
              icon: const Icon(Icons.add),
              onPressed: _showAddDialog,
            ),
            IconButton(
              tooltip: l10n.tooltipClear,
              icon: const Icon(Icons.clear),
              onPressed: () {
                _textController.clear();
              },
            ),
            IconButton(
              tooltip: l10n.tooltipSearch,
              icon: Icon(
                Icons.search,
                color: _isSearchEnabled
                    ? Theme.of(context).floatingActionButtonTheme.foregroundColor
                    : Theme.of(context).disabledColor,
              ),
              onPressed:
                  _isSearchEnabled ? () => showResult(_textController.text) : null,
            ),
          ],
        ),
        body: _buildBody(l10n));
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_favoriteTags.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            l10n.searchFavoriteTagsEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            l10n.searchFavoriteTagsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List<Widget>.generate(_favoriteTags.length, (index) {
                final tag = _favoriteTags[index];
                final tc = getTagCategory(tag, 0, Booru.derpi);
                return GestureDetector(
                  key: ValueKey('fav-tag-$tag'),
                  onTap: () => _appendTagToInput(tag),
                  onLongPress: () => _deleteFavoriteTag(tag),
                  child: Chip(
                    label: Text(tag,
                        style: TextStyle(
                            color: tagForeColor(
                                tc, Theme.of(context).brightness))),
                    backgroundColor: tagBackColors[tc] ?? Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
