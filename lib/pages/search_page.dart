import 'package:derpiviewer/models/search_model.dart';
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

  @override
  void initState() {
    _initQuery = widget.initQuery ?? "";
    _textController.text = _initQuery;
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void showResult(query) {
    Provider.of<SearchModel>(context, listen: false).newSearch(query);
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
            style: const TextStyle(
              color: Colors.white,
              decorationColor: Colors.white,
            ),
            cursorColor: Colors.white,
          ),
          actions: [
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                // _textController.text = '';
                _textController.clear();
              },
            ),
            IconButton(
                onPressed: () => showResult(_textController.text),
                icon: const Icon(Icons.search))
          ],
        ),
        body: Container());
  }
}
