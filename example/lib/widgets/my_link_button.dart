import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class MyLinkButton extends StatefulWidget {
  const MyLinkButton({
    required this.controller,
    this.iconSize = quill.kDefaultIconSize,
    this.icon,
    Key? key,
  }) : super(key: key);

  final quill.QuillController controller;
  final IconData? icon;
  final double iconSize;

  @override
  _MyLinkButtonState createState() => _MyLinkButtonState();
}

class _MyLinkButtonState extends State<MyLinkButton> {
  void _didChangeSelection() {
    setState(() {});
  }

  String? linkValue;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant MyLinkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      widget.controller.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_didChangeSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!widget.controller.selection.isCollapsed) {
      var attributes = widget.controller.getSelectionStyle().attributes;
      print('build attributes --> $attributes');
      if (attributes.isNotEmpty) {
        print('build attributes --> $attributes');
        attributes.forEach((key, value) {
          if (key == 'link') {
            linkValue =
                widget.controller.getSelectionStyle().attributes['link']!.value;

            print('build linkValue --> $linkValue');
            return;
          }
        });
      }
    }

    final isEnabled = !widget.controller.selection.isCollapsed;
    final pressedHandler =
        isEnabled ? () => _openLinkDialog(context, linkValue) : null;

    return quill.QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * quill.kIconButtonFactor,
      icon: Icon(
        widget.icon ?? Icons.link,
        size: widget.iconSize,
        color: isEnabled ? theme.iconTheme.color : theme.disabledColor,
      ),
      fillColor: Theme.of(context).canvasColor,
      onPressed: pressedHandler,
    );
  }

  void _openLinkDialog(BuildContext context, String? linkValue) {
    print('_openLinkDialog linkValue --> $linkValue');
    showDialog<String>(
      context: context,
      builder: (ctx) {
        return _LinkDialog(
          linkValue: linkValue,
        );
      },
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value == null || value.isEmpty) {
      quill.Attribute.clone(quill.Attribute.link, null); // return;
    }
    widget.controller.formatSelection(quill.LinkAttribute(value));
  }
}

class _LinkDialog extends StatefulWidget {
  final linkValue;
  const _LinkDialog({Key? key, this.linkValue}) : super(key: key);

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  String? _link;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('_LinkDialog initState widget.linkValue --> ${widget.linkValue}');
    _link = widget.linkValue ?? '';
    _controller.text = widget.linkValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Paste a link'),
        autofocus: true,
        onChanged: _linkChanged,
      ),
      actions: [
        TextButton(
          onPressed: _link!.isNotEmpty ? _applyLink : null,
          child: const Text('Apply'),
        ),
        TextButton(
          onPressed: _removeLink,
          child: const Text('Remove'),
        ),
      ],
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, _link);
  }

  void _removeLink() {
    setState(() {
      _link = '';
    });
    Navigator.pop(context, null);
  }
}
