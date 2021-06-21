import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'hashtag_button.dart';
import 'mention_button.dart';
import 'my_link_button.dart';
import 'my_toggle_style_button.dart';

class CustomToolbar extends QuillToolbar {
  final QuillController controller;

  CustomToolbar(this.controller)
      : super(children: [
          HistoryButton(
            icon: Icons.undo_outlined,
            controller: controller,
            undo: true,
          ),
          HistoryButton(
            icon: Icons.redo_outlined,
            controller: controller,
            undo: false,
          ),
          const SizedBox(width: 0.6),
          MyToggleStyleButton(
            attribute: Attribute.bold,
            icon: Icons.format_bold,
            controller: controller,
          ),
          const SizedBox(width: 0.6),
          MyToggleStyleButton(
            attribute: Attribute.italic,
            icon: Icons.format_italic,
            controller: controller,
          ),
          const SizedBox(width: 0.6),
          MyToggleStyleButton(
            attribute: Attribute.underline,
            icon: Icons.format_underline,
            controller: controller,
          ),
          const SizedBox(width: 0.6),
          MyToggleStyleButton(
            attribute: Attribute.ol,
            controller: controller,
            icon: Icons.format_list_numbered,
          ),
          MyToggleStyleButton(
            attribute: Attribute.ul,
            controller: controller,
            icon: Icons.format_list_bulleted,
          ),
          MyLinkButton(
            controller: controller,
          ),
          MentionButton(
              attribute: Attribute.mention,
              icon: Icons.person,
              controller: controller,
              undo: true),
          HashtagButton(
              attribute: Attribute.hashtag,
              icon: Icons.tag,
              controller: controller,
              undo: true),
        ]);

  //CustomToolbarState createState() =>CustomToolbarState();
}
/*class CustomToolbarState extends QuillToolbar<CustomToolbarState>{
  @override
  Widget build(BuildContext context){
    return Container(child: super.bsuild(context));
  }
}*/
