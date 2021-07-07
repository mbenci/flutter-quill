import 'package:app/widgets/mention_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../util.dart';

class MentionButton extends StatefulWidget {
  const MentionButton({
    required this.attribute,
    required this.icon,
    required this.controller,
    required this.undo,
    this.iconSize = quill.kDefaultIconSize,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final bool undo;
  final quill.QuillController controller;
  final quill.Attribute attribute;

  @override
  _MentionButtonState createState() => _MentionButtonState();
}

class _MentionButtonState extends State<MentionButton> {
  Color? _iconColor;
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    final fillColor = theme.canvasColor;

    return quill.QuillIconButton(
        highlightElevation: 0,
        hoverElevation: 0,
        size: widget.iconSize * 1.77,
        icon: Icon(widget.icon, size: widget.iconSize, color: _iconColor),
        fillColor: fillColor,
        onPressed: () {
          showMentionDialog(context, widget.controller);
        });
  }
}
