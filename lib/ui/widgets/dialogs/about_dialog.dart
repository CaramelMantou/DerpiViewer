import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineSmall: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      child: AboutDialog(
        applicationName: 'DerpiViewer',
        applicationVersion: '1.1.0',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Author:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('CaramelMantou@github'),
                const SizedBox(height: 8),
                const Text('Github Repository:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(
                  'https://github.com/CaramelMantou/derpiviewer',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    launchUrl(Uri.parse(
                        'https://github.com/CaramelMantou/derpiviewer'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
