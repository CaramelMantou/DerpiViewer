import 'package:derpiviewer/helpers/cache_helper.dart';
import 'package:derpiviewer/models/pref_model.dart';
import 'package:derpiviewer/core/domain/search_interface.dart';
import 'package:derpiviewer/pages/gallery.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ImageGrid extends StatefulWidget {
  final SearchInterface model;
  const ImageGrid({super.key, required this.model});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  late SearchInterface _model;
  @override
  void initState() {
    _model = widget.model;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSingleColumn = Provider.of<PrefModel>(context).isSingleColumn;
    return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSingleColumn ? 1 : 2, // 根据模式切换列数
            childAspectRatio: 1.0,
            mainAxisSpacing: 7.0,
            crossAxisSpacing: 7.0),
        delegate: SliverChildBuilderDelegate(
            (context, index) => ThumbHero(
                photo: isSingleColumn
                    ? _model.getItemMediumThumbUrl(index)
                    : _model.getItemThumbUrl(index),
                idTag: _model.getItemID(index),
                onTap: (() => goto(index))),
            childCount: _model.getItemCount()));
  }

  void goto(int index) {
    Navigator.of(context).push(MaterialPageRoute<int>(
        builder: ((context) => GalleryView(
              model: _model,
              startIndex: index,
            ))));
  }
}

class ThumbHero extends StatelessWidget {
  const ThumbHero(
      {Key? key, required this.photo, required this.idTag, required this.onTap})
      : super(key: key);

  final String photo;
  final int idTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Hero(
        tag: idTag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
              cacheManager: ImageCacheManager(),
            ),
          ),
        ),
      ),
    );
  }
}
