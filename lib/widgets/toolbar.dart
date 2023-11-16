import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/helpers/db.dart';
import 'package:derpiviewer/helpers/download.dart';
import 'package:derpiviewer/models/search_model.dart';
import 'package:derpiviewer/widgets/detail.dart';
import 'package:derpiviewer/widgets/icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GalleryToolBar extends StatelessWidget {
  final SearchInterface model;
  int index;
  ToolbarController controller;
  FavIconController favController = FavIconController();
  GalleryToolBar(
      {super.key,
      required this.model,
      required this.index,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller,
      builder: (context, index, child) {
        return Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(bottom: 8, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FutureBuilder<bool>(
                  future: DbHelper.getFavorite(
                      model.getBooru(), model.getItemID(index)),
                  builder: (context, snapshot) {
                    favController.value = snapshot.data ?? false;
                    return GestureDetector(
                      child: FavIcon(
                        controller: favController,
                      ),
                      onTap: () {
                        favController.toggleFav();
                        if (favController.value) {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.toolbar1n1);
                        } else {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.toolbar1n2);
                        }
                        DbHelper.putFavorite(model.getBooru(),
                            model.getItem(index), favController.value);
                      },
                    );
                  },
                ),
              ),
              Expanded(
                  child: IconButton(
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
                onPressed: () async {
                  int idx = index;
                  if (model.getItemFormat(idx) == ContentFormat.webm) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.toolbar2n1);
                  }
                  DownloadHelper.downloadFile(
                      model.getItemUrl(idx, model.getPref().downloadSize),
                      model.getBooru(),
                      model.getItemID(idx),
                      ConstStrings.format[model.getItemFormat(idx).index]);
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.toolbar2n1);
                },
              )),
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: ((context) {
                              int idx = index;
                              var imageresponse = model.getItem(idx);
                              return Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        int idx = index;
                                        DownloadHelper.shareFile(
                                            model.getItemUrl(
                                                idx,
                                                (model.getItemFormat(idx) ==
                                                        ContentFormat.webm)
                                                    ? Size.thumb
                                                    : model
                                                        .getPref()
                                                        .shareSize),
                                            model.getBooru(),
                                            model.getItemID(idx),
                                            model.getItemFormat(idx));
                                      },
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .toolbar3o1,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        DownloadHelper.shareLink(
                                            model.getBooru(),
                                            model.getItemID(idx));
                                        Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!
                                                .toolbar3n1);
                                      },
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .toolbar3o2,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }));
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ))),
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: ((context) {
                              int idx = index;
                              var imageresponse = model.getItem(idx);
                              return DetailSheet(image: imageresponse);
                            }));
                      },
                      icon: const Icon(
                        Icons.info,
                        color: Colors.white,
                      )))
            ],
          ),
        );
      },
    );
  }

  Widget buildItem(String title, BuildContext context, {Function? onTap}) {
    //添加点击事件
    return InkWell(
      //点击回调
      onTap: () {
        //关闭弹框
        Navigator.of(context).pop();
        //外部回调
        if (onTap != null) {
          onTap();
        }
      },
      child: SizedBox(
        height: 40,
        //左右排开的线性布局
        child: Row(
          //所有的子Widget 水平方向居中
          mainAxisAlignment: MainAxisAlignment.center,
          //所有的子Widget 竖直方向居中
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}

class ToolbarController extends ValueNotifier<int> {
  ToolbarController(int index) : super(index);
  void change(int index) {
    value = index;
  }
}
