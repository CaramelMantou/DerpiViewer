import 'package:derpiviewer/core/domain/view_state.dart';
import 'package:derpiviewer/ui/providers/search_provider.dart';
import 'package:derpiviewer/ui/widgets/error_view.dart';
import 'package:derpiviewer/ui/widgets/skeleton_grid.dart';
import 'package:derpiviewer/widgets/image_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  final String query;
  const ResultPage({super.key, required this.query});

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
    _scrollController.addListener(_scrollCallback);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollCallback() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<SearchProvider>(context, listen: false).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return switch (provider.state) {
          LoadingState() => const SkeletonGrid(),
          SuccessState(data: final images) => () {
              if (images.isEmpty) {
                return _buildEmptyState(context, provider);
              }
              return CustomScrollView(
                slivers: <Widget>[
                  ImageGrid(model: provider),
                ],
                controller: _scrollController,
              );
            }(),
          FailureState(message: final msg, type: final _) => ErrorView(
              message: msg,
              onRetry: () => provider.newSearch(provider.query),
            ),
        };
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, SearchProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              "No results for '${provider.query}'",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different search terms or check your filter settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
