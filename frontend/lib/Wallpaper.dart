import 'package:flutter/material.dart';

class Wallpaper extends StatelessWidget {
  final double width;
  final double height;
  Wallpaper(this.width, this.height);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(56),
            bottomRight: Radius.circular(56),
          ),
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                offset: Offset(0, 4),
                blurRadius: 4)
          ],
          color: Color.fromRGBO(44, 111, 255, 1),
        ));
  }
}
