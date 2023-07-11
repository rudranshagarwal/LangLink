import 'package:flutter/material.dart';

class Text1 extends StatelessWidget {
  final String textString;
  final String font;
  final double fontSize;

  const Text1(
      {required this.textString, required this.font, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      textString,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 1),
        fontFamily: font,
        fontSize: fontSize,
      ),
    );
  }
}
