import 'package:flutter/material.dart';

class FavIcon extends StatefulWidget {
  FavIconController controller;
  FavIcon({super.key, required this.controller});
  @override
  _FavIconState createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {
  late FavIconController controller;
  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller,
      builder: (context, isFav, child) {
        return Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        );
      },
    );
  }
}

class FavIconController extends ValueNotifier<bool> {
  FavIconController() : super(false);

  void toggleFav() {
    value = !value;
  }
}
