import 'package:derpiviewer/enums.dart';
import 'package:derpiviewer/helpers/helper.dart';
import 'package:derpiviewer/helpers/philomena_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DetailSheet extends StatefulWidget {
  ImageResponse image;
  DetailSheet({super.key, required this.image});

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late ImageResponse _image;
  late List<String> _tags;
  @override
  void initState() {
    _image = widget.image;
    _tags = _image.tags;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _image.id.toString()));
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.toolbar4n1);
                },
                child: Chip(
                    label: Text(
                  "ID: ${_image.id}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )))),
        Align(
            alignment: Alignment.centerLeft,
            child:
                Text(_image.uploader == "" ? "Unknown Pony" : _image.uploader,
                    style: const TextStyle(
                      fontSize: 18,
                    ))),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('yyyy-MM-dd HH:mm')
                  .format(DateTime.parse(_image.createdAt)),
            )),
        const SizedBox(
          height: 8,
        ),
        Text(_image.description),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.thumb_up,
                    color: Colors.green,
                  ),
                  Text("${_image.upvotes}",
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.thumb_down,
                    color: Colors.red,
                  ),
                  Text("${_image.downvotes}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow[800],
                  ),
                  Text(
                    "${_image.faves}",
                    style: TextStyle(
                        color: Colors.yellow[800], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.comment,
                    color: Colors.purple[200],
                  ),
                  Text("${_image.comments}",
                      style: TextStyle(
                        color: Colors.purple[200],
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        const Text(
          "Tags: ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
        Wrap(
            spacing: 8.0, // 水平方向上的间距
            runSpacing: 4.0, // 垂直方向上的间距
            children: List<Widget>.generate(_tags.length, (index) {
              var tc = getTagCategory(_tags[index]);
              return GestureDetector(
                  onTap: () {
                    appendClipboard(
                        AppLocalizations.of(context)!.toolbar4n2, _tags[index]);
                    // Navigator.pop(context);
                  },
                  child: Chip(
                    label: Text(_tags[index],
                        style:
                            TextStyle(color: ConstStrings.tagForeColors[tc])),
                    backgroundColor: ConstStrings.tagBackColors[tc],
                  ));
            }))
      ],
    );
  }
}
