import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String text;
  final bool color;

  Message(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 50,
          width: 300,
          decoration: BoxDecoration(
            color: color ? const Color.fromRGBO(44, 111, 255, 1) : const Color.fromRGBO(222, 234, 255, 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
