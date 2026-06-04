import 'package:derpiviewer/ui/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:derpiviewer/pages/result_page.dart';
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

  @override
  void initState() {
    _initQuery = widget.initQuery ?? "";
    _textController.text = _initQuery;
    _isSearchEnabled = _initQuery.isNotEmpty;
    _textController.addListener(_onTextChanged);
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
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
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
                hintText: '搜索...',
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
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _textController.clear();
              },
            ),
            IconButton(
              tooltip: 'Search',
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
        body: Container());
  }
}
