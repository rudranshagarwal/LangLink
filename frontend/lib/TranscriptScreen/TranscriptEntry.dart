import 'package:flutter/material.dart';
import '../CallScreen/message.dart';
import '../globals.dart' as globals;

class Entry extends StatelessWidget {

  final height;
  Map<String, dynamic> entry;

  Entry(this.entry, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: height / 50),
        Container(
          alignment: entry['SenderID'] == globals.userID
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Message(
            entry['SenderID'] == globals.userID
            ? entry['SentText']
            : entry['TranslatedText'],
            entry['SenderID'] == globals.userID && entry['SentByChatBot']
          )
        )
      ],
    );
  }
}