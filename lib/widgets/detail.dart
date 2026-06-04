import 'package:derpiviewer/api/do.dart';
import 'package:derpiviewer/config/tag_categories.dart';
import 'package:derpiviewer/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_tags/flutter_tags.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailSheet extends StatefulWidget {
  ImageResponse image;
  DetailSheet({super.key, required this.image});

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late ImageResponse _image;
  late List<String> _tags;
  late List<int> _tagids;
  @override
  void initState() {
    _image = widget.image;
    _tags = _image.tags;
    _tagids = _image.tagids;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final numberFormat = NumberFormat.decimalPattern(locale.languageCode);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _image.id.toString()));
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.toolbarCopyId);
                },
                child: Chip(
                    label: Text(
                  "ID: ${_image.id}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                )))),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
                _image.uploader == "" ? "Background Pony" : _image.uploader,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 40, 135, 203)))),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat.yMd(locale.languageCode).add_jm()
                  .format(DateTime.parse(_image.createdAt)),
            )),
        const SizedBox(
          height: 8,
        ),
        MarkdownBody(
            selectable: true,
            onTapLink: (text, href, title) async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        Text(AppLocalizations.of(context)!.toolbarConfirmTitle),
                    content: Text(
                        AppLocalizations.of(context)!.toolbarConfirmMessage),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                            AppLocalizations.of(context)!.toolbarConfirmOk),
                        onPressed: () async {
                          Navigator.pop(context);
                          if (await canLaunchUrl(Uri.parse(href ?? ""))) {
                            await launchUrl(Uri.parse(href ?? ""));
                          } else {
                            return;
                          }
                        },
                      ),
                      TextButton(
                        child: Text(
                            AppLocalizations.of(context)!.toolbarConfirmCancel),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );
            },
            data: _image.description == ""
                ? "No description"
                : _image.description),
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
                  Text(numberFormat.format(_image.upvotes),
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
                  Text(numberFormat.format(_image.downvotes),
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
                    numberFormat.format(_image.faves),
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
                  Text(numberFormat.format(_image.comments),
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
              var tc =
                  getTagCategory(_tags[index], _tagids[index], _image.booru);
              return GestureDetector(
                  onTap: () {
                    appendClipboard(
                        AppLocalizations.of(context)!.toolbarCopyTag,
                        _tags[index]);
                    // Navigator.pop(context);
                  },
                  child: Chip(
                    label: Text(_tags[index],
                        style:
                            TextStyle(color: tagForeColor(tc, Theme.of(context).brightness))),
                    backgroundColor: tagBackColors[tc] ?? Colors.grey,
                  ));
            }))
      ],
    );
  }
}
