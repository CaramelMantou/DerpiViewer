import 'package:derpiviewer/models/pref_model.dart';
import 'package:flutter/material.dart';

class ChangeSlideIntervalDialog extends StatelessWidget {
  final PrefModel pref;
  const ChangeSlideIntervalDialog({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置幻灯片间隔'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('当前间隔: ${pref.slideInterval}秒'),
          Slider(
            value: pref.slideInterval.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '${pref.slideInterval}秒',
            onChanged: (value) {
              pref.setSlideInterval(value.round());
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
