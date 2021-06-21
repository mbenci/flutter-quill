import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/models/documents/style.dart';

typedef ToggleStyleButtonBuilder = Widget Function(
  BuildContext context,
  quill.Attribute attribute,
  IconData icon,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed, [
  double iconSize,
]);

class MyToggleStyleButton extends StatefulWidget {
  const MyToggleStyleButton({
    required this.attribute,
    required this.icon,
    required this.controller,
    this.iconSize = quill.kDefaultIconSize,
    this.fillColor,
    this.childBuilder = defaultToggleStyleButtonBuilder,
    Key? key,
  }) : super(key: key);

  final quill.Attribute attribute;

  final IconData icon;
  final double iconSize;

  final Color? fillColor;

  final quill.QuillController controller;

  final ToggleStyleButtonBuilder childBuilder;

  @override
  _MyToggleStyleButtonState createState() => _MyToggleStyleButtonState();
}

class _MyToggleStyleButtonState extends State<MyToggleStyleButton> {
  bool? _isToggled;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  Widget build(BuildContext context) {
    final isInCodeBlock =
        _selectionStyle.attributes.containsKey(quill.Attribute.codeBlock.key);
    final isAMention =
        _selectionStyle.attributes.containsKey(quill.Attribute.mention.key);
    final isAHashtag =
        _selectionStyle.attributes.containsKey(quill.Attribute.hashtag.key);
    final isEnabled = !isAMention &&
        !isAHashtag &&
        (!isInCodeBlock ||
            widget.attribute.key == quill.Attribute.codeBlock.key);
    return widget.childBuilder(
      context,
      widget.attribute,
      widget.icon,
      widget.fillColor,
      _isToggled,
      isEnabled ? _toggleAttribute : null,
      widget.iconSize,
    );
  }

  @override
  void didUpdateWidget(covariant MyToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  void _didChangeEditingValue() {
    setState(() => _isToggled = _getIsToggled(_selectionStyle.attributes));
  }

  bool _getIsToggled(Map<String, quill.Attribute> attrs) {
    if (widget.attribute.key == quill.Attribute.list.key) {
      final attribute = attrs[widget.attribute.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == widget.attribute.value;
    }
    return attrs.containsKey(widget.attribute.key);
  }

  void _toggleAttribute() {
    widget.controller.formatSelection(_isToggled!
        ? quill.Attribute.clone(widget.attribute, null)
        : widget.attribute);
  }
}

Widget defaultToggleStyleButtonBuilder(
  BuildContext context,
  quill.Attribute attribute,
  IconData icon,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed, [
  double iconSize = quill.kDefaultIconSize,
]) {
  final theme = Theme.of(context);
  final isEnabled = onPressed != null;
  final iconColor = isEnabled
      ? isToggled == true
          ? theme.primaryIconTheme.color
          : theme.iconTheme.color
      : theme.disabledColor;
  final fill = isToggled == true
      ? theme.toggleableActiveColor
      : fillColor ?? theme.canvasColor;
  return quill.QuillIconButton(
    highlightElevation: 0,
    hoverElevation: 0,
    size: iconSize * quill.kIconButtonFactor,
    icon: Icon(icon, size: iconSize, color: iconColor),
    fillColor: fill,
    onPressed: onPressed,
  );
}
