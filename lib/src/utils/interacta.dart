import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quill/src/models/documents/attribute.dart';
import 'package:flutter_quill/src/widgets/controller.dart';
import 'package:flutter_quill/src/widgets/editor.dart';

class InteractaInfo {
  String prevText;
  int prevLength;
  int prevCursorPosition;

  String get text {
    return prevText;
  }

  int get position {
    return prevCursorPosition;
  }

  int get length {
    return prevLength;
  }

  set text(String _prevText) {
    prevText = _prevText;
  }

  set position(int _prevCursorPosition) {
    prevCursorPosition = _prevCursorPosition;
  }

  set length(int _prevLength) {
    prevLength = _prevLength;
  }

  InteractaInfo(
      {required this.prevText,
      required this.prevLength,
      required this.prevCursorPosition});
}

InteractaInfo? interactChecks(
    QuillController controller,
    RenderEditor? getRenderEditor,
    InteractaInfo? interactaInfo,
    Function(bool, String?) callback) {
  interactaInfo ??=
      InteractaInfo(prevText: '', prevLength: 0, prevCursorPosition: 0);
  final selection = controller.selection;
  final cursorPosition = selection.start;
  final prevLength = (interactaInfo != null) ? interactaInfo.length : 0;
  final diff = controller.document.toPlainText().length - prevLength;

  print('diff--> $diff');
  print('prevLength--> ${interactaInfo.length}');
  print('length--> ${controller.document.toPlainText().length}');
  print('cursorPosition--> $cursorPosition');
  print('prevCursorPosition--> ${interactaInfo.prevCursorPosition}');
  print('document--> ${controller.document.toDelta()}');

  if (diff != 0) {
    if (showHashtagDialog(cursorPosition, controller)) {
      callback(true, null);
    } else if (showMentionDialog(cursorPosition, controller)) {
      callback(false, null);
    } else if (cursorPosition > 0) {
      if (diff > 0) {
        checkIfIsHashtagOrMentionCloseInsert(
            cursorPosition, controller, getRenderEditor);
      } else if (diff < 0) {
        checkIfIsHashtagOrMentionRemoving(
            cursorPosition, interactaInfo.text, controller, getRenderEditor);
      }
    }
  }

  interactaInfo
    ..text = controller.document.toPlainText()
    ..length = controller.document.toPlainText().length
    ..position = cursorPosition;

  return interactaInfo;
}

void checkIfIsHashtagOrMentionRemoving(int cursorPosition, String prevText,
    QuillController controller, RenderEditor? getRenderEditor) {
  print(prevText[cursorPosition]);
  if (prevText[cursorPosition] == ' ' ||
      prevText[cursorPosition] == '\n' ||
      prevText[cursorPosition] == '' ||
      prevText[cursorPosition].isEmpty) {
    return;
  }
  final isHashtagOrMention = controller
          .getSelectionStyleRange(cursorPosition - 1, 1)
          .containsKey(Attribute.hashtag.key) ||
      controller
          .getSelectionStyleRange(cursorPosition - 1, 1)
          .containsKey(Attribute.mention.key);
  print('isHashtagOrMention --> $isHashtagOrMention');

  if (isHashtagOrMention) {
    final sel = getRenderEditor!
        .selectWordAtPosition(TextPosition(offset: cursorPosition - 2));
    controller.replaceText(
        sel.baseOffset - 1,
        sel.extentOffset - sel.baseOffset,
        '',
        TextSelection.collapsed(offset: sel.baseOffset - 1));
  }
}

void checkIfIsHashtagOrMentionCloseInsert(int cursorPosition,
    QuillController controller, RenderEditor? getRenderEditor) {
  final isHashtagOrMention = controller
          .getSelectionStyleRange(cursorPosition - 1, 1)
          .containsKey(Attribute.hashtag.key) ||
      controller
          .getSelectionStyleRange(cursorPosition - 1, 1)
          .containsKey(Attribute.mention.key);

  if (isHashtagOrMention) {
    final sel = getRenderEditor!
        .selectWordAtPosition(TextPosition(offset: cursorPosition - 2));

    /*
      print('sel--> $sel');
      print(widget.controller.document.toPlainText()[sel.baseOffset - 1]);
      print(sel.extentOffset - sel.baseOffset);
      print(widget.controller.document.toPlainText()[cursorPosition]);
      print('isHashtagOrMention--> isHashtagOrMention');
       */

    controller.replaceText(
        sel.baseOffset - 1,
        cursorPosition + 1 - sel.baseOffset,
        '',
        TextSelection.collapsed(offset: sel.baseOffset - 1));
  }
}

bool showHashtagDialog(int cursorPosition, QuillController controller) {
  return cursorPosition > 0 &&
      controller.document.toPlainText()[cursorPosition - 1] == '#' &&
      (cursorPosition == 1 ||
          cursorPosition > 1 &&
              (controller.document.toPlainText()[cursorPosition - 2] == ' ' ||
                  controller.document.toPlainText()[cursorPosition - 2] ==
                      '\n' ||
                  controller.document.toPlainText()[cursorPosition - 2] == '' ||
                  controller.document
                      .toPlainText()[cursorPosition - 2]
                      .isEmpty));
}

bool showMentionDialog(int cursorPosition, QuillController controller) {
  return cursorPosition > 0 &&
      controller.document.toPlainText()[cursorPosition - 1] == '@' &&
      (cursorPosition == 1 ||
          cursorPosition > 1 &&
              (controller.document.toPlainText()[cursorPosition - 2] == ' ' ||
                  controller.document.toPlainText()[cursorPosition - 2] ==
                      '\n' ||
                  controller.document.toPlainText()[cursorPosition - 2] == '' ||
                  controller.document
                      .toPlainText()[cursorPosition - 2]
                      .isEmpty));
}
