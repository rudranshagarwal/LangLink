import 'package:flutter/material.dart';
import '../Text.dart';
import './Wallpaper.dart';

class Logo extends StatelessWidget {
  final double width;
  final double height;
  const Logo(this.width, this.height, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        width: width,
        child: Stack(children: <Widget>[
          Wallpaper(width, height),
          Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: height / 2,
                  ),
                  Container(
                    child: const Text1(
                      textString: 'LangLink',
                      font: 'Arima Madurai',
                      fontSize: 64,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text1(
                      textString: 'Overcoming Language Barriers',
                      font: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
        ]));
  }
}
