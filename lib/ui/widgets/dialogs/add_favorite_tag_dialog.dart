import 'package:derpiviewer/core/di/injection_container.dart';
import 'package:derpiviewer/core/domain/repositories/favorite_tags_repository.dart';
import 'package:derpiviewer/core/domain/result.dart';
import 'package:derpiviewer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddFavoriteTagDialog extends StatefulWidget {
  const AddFavoriteTagDialog({super.key});

  @override
  State<AddFavoriteTagDialog> createState() => _AddFavoriteTagDialogState();
}

class _AddFavoriteTagDialogState extends State<AddFavoriteTagDialog> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.searchAddFavoriteTag),
      content: TextField(
        controller: _textController,
        autofocus: true,
        enabled: !_isSubmitting,
        textInputAction: TextInputAction.done,
        onSubmitted:
            _isSubmitting ? null : (value) => _submit(value.trim()),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: l10n.searchAddFavoriteTagHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.toolbarConfirmCancel),
        ),
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => _submit(_textController.text.trim()),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dialogOk),
        ),
      ],
    );
  }

  void _submit(String tag) {
    if (tag.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final repository = resolve<FavoriteTagsRepository>();
    repository.addTag(tag).then((result) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (result is Success<void>) {
        Fluttertoast.showToast(msg: l10n.searchTagAdded);
        navigator.pop(tag);
      } else if (result is Failure<void>) {
        Fluttertoast.showToast(msg: result.message);
      }
    });
  }
}
