import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

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
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Mentions List'),
                content: setupAlertDialoadContainer(),
                actions: <Widget>[
                  TextButton(
                    child: const Text('ok'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      // true here means you clicked ok
                    },
                  ),
                ],
              );
            }).then((val) {
          final start = widget.controller.selection.start;
          final length = start + '#mention'.length;

          widget.controller.replaceText(
            start,
            0,
            '#mention',
            TextSelection.collapsed(offset: length),
          );

          widget.controller
              .formatText(start, '#mention'.length, quill.Attribute.mention);

          widget.controller.replaceText(
            length,
            0,
            ' ',
            TextSelection.collapsed(offset: length + 1),
          );
          widget.controller.formatText(length, ' '.length,
              quill.Attribute.clone(quill.Attribute.mention, null));
        });
      },
    );
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 300, // Change as per your requirement
      width: 300, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('mention$index'),
          );
        },
      ),
    );
  }
}
