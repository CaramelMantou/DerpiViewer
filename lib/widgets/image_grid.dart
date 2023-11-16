import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/pages/gallery.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisSpacing: 7.0,
            crossAxisSpacing: 7.0),
        delegate: SliverChildBuilderDelegate(
            (context, index) => ThumbHero(
                photo: _model.getItemUrl(index, Size.small),
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
            ),
          ),
        ),
      ),
    );
  }
}
