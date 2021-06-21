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
    //_setIconColor();

    final fillColor = theme.canvasColor;
    /* widget.controller.changes.listen((event) async {
      _setIconColor();
    });*/
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
                title: const Text('Mention List'),
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
          final end = widget.controller.selection.end -
              widget.controller.selection.start;
          final length = start + '@mention '.length;

          widget.controller.replaceText(
            start,
            end,
            '@mention ',
            TextSelection.collapsed(offset: length),
          );
          //print(widget.controller.document.toPlainText());
          widget.controller
              .formatText(start, '@mention'.length, widget.attribute);
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

  /*void _setIconColor() {
    if (!mounted) return;

    if (widget.undo) {
      setState(() {
        _iconColor = widget.controller.hasUndo
            ? theme.iconTheme.color
            : theme.disabledColor;
      });
    } else {
      setState(() {
        _iconColor = theme.iconTheme.color;
      });
    }
  }*/
}
