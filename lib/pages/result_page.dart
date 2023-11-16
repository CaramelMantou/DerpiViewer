import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  late String query;
  ResultPage({super.key, required this.query});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Searching: ${widget.query}"),
      ),
      body: const ResultScroll(),
    );
  }
}

class ResultScroll extends StatefulWidget {
  const ResultScroll({super.key});
  @override
  State<ResultScroll> createState() => _ResultScrollState();
}

class _ResultScrollState extends State<ResultScroll> {
  late ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(scrollCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        Consumer<SearchModel>(
            builder: ((context, value, child) => ImageGrid(
                  model: value,
                )))
      ],
      controller: _scrollController,
    );
  }

  void scrollCallback() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<SearchModel>(context, listen: false).fetchMore();
    }
  }
}
