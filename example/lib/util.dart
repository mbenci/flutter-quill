import 'package:app/widgets/hashtag_dialog.dart';
import 'package:app/widgets/mention_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void showHashtagDialog(BuildContext context, quill.QuillController controller,
        {bool specialChar = false}) =>
    showDialog(
        context: context,
        builder: (context) {
          return const HashtagDialog();
        }).then((val) {
      print(val);
      final start = specialChar
          ? controller.selection.start - 1
          : controller.selection.start;
      final length = start + '#hashtag'.length;

      //print('start --> $start');

      controller
        ..replaceText(
          start,
          specialChar ? 1 : 0,
          '#hashtag',
          TextSelection.collapsed(offset: length),
        )
        ..formatText(start, '#hashtag'.length, quill.HashtagAttribute('456'))
        ..replaceText(
          length,
          0,
          ' ',
          TextSelection.collapsed(offset: length + 1),
        )
        ..formatText(start + '#hashtag'.length, 1,
            quill.Attribute.clone(quill.Attribute.hashtag, null));
    });

void showMentionDialog(BuildContext context, quill.QuillController controller,
        {bool specialChar = false}) =>
    showDialog(
        context: context,
        builder: (context) {
          return const MentionDialog();
        }).then((val) {
      final start = specialChar
          ? controller.selection.start - 1
          : controller.selection.start;

      //print('start --> $start');

      final length = start + '@mention'.length;
      controller
        ..replaceText(
          start,
          specialChar ? 1 : 0,
          '@mention',
          TextSelection.collapsed(offset: length),
        )
        ..formatText(start, '@mention'.length, quill.MentionAttribute('123'))
        ..replaceText(
          length,
          0,
          ' ',
          TextSelection.collapsed(offset: length + 1),
        )
        ..formatText(length, ' '.length,
            quill.Attribute.clone(quill.Attribute.mention, null));
    });
