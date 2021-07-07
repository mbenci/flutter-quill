import 'package:flutter/material.dart';

class MentionDialog extends StatelessWidget {
  const MentionDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
